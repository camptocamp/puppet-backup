# == Class: backup::mysql
#
# Enable mysql daily backup script.
#
# The script /usr/local/bin/mysql-backup.sh will be run every night. It runs
# mysqldump --all-databases. Backups will be stored in /var/backups/mysql.
#
# Attributes:
# - $mysqldump_retention: defines if backup rotate on a weekly, monthly or
#   yearly basis. Accepted values: 'week', 'month', 'year'. Defaults to 'week'.
# - $mysql_backupdir: defines backup location
#   Default value: '/var/backups/mysql'
# - $mysqldump_options: defines options passed to mysqldump command.
#   Please refer to the manpage.
#   Default value: '--all-database --extended-insert'
# - $mysql_post_backup_hook: defines commands to be called after the backup is
#   made, gzipped and moved to $backup_dir/mysql-$date.sql.gz, where $day is the
#   day of the week.
#
class backup::mysql(
  $data_dir               = $::mysql::server::options['mysqld']['datadir'],
  $backup_dir             = '/var/backups/mysql',
  $cron_hour              = '2',
  $cron_minute            = '0',
  $mysqldump_retention    = 'week',
  $mysqldump_options      = '--all-databases --extended-insert',
  $mysql_post_backup_hook = undef,
) {

  validate_re( $cron_hour, '^\d+$' )
  validate_re( $cron_minute, '^\d+$' )

  ensure_resource(
    'group',
    'mysql-admin',
    {
      ensure => present,
      system => true,
    }
  )

  file { $backup_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'mysql-admin',
    mode    => '0750',
    require => Group['mysql-admin'],
  }

  file {'/usr/local/bin/mysql-backup.sh':
    ensure  => file,
    content => template('backup/mysql-backup.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
  }

  cron {'mysql-backup':
    command => "/usr/local/bin/mysql-backup.sh ${mysqldump_retention} > ${backup_dir}/backup-logs-$(date '+%Y-%m-%d') 2&>1",
    user    => 'root',
    hour    => $cron_hour,
    minute  => $cron_minute,
    require => [File[$backup_dir], File['/usr/local/bin/mysql-backup.sh']],
  }

}
