# == Class:  backup::mongodb
#
# Enable mongodb daily backup script.
#
#
class backup::mongodb(
  $mongo_admin_password,
  $mongo_post_backup = undef,
  $backup_dir = '/srv/mongo-bkp',
) {
  file {'/usr/local/bin/mongodb-backup.sh':
    ensure  => file,
    content => template('backup/mongodb-backup.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0500',
  }

  cron {'mongodb backup':
    command => '/usr/local/bin/mongodb-backup.sh',
    user    => 'root',
    minute  => '0',
    hour    => '3',
  }
}
