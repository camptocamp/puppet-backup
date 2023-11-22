# == Class:  backup::mongodb
#
# Enable mongodb daily backup script.
#
#
class backup::mongodb(
  $mongo_version,
  $mongo_admin_password,
  $backup_dir = '/srv/mongo-bkp',
  $mongo_post_backup = undef,
  $mongo_pre_backup = undef,
) {
  package { 'mongodb-org-tools':
    ensure =>  $mongo_version,
  }

  file { ["${backup_dir}", "${backup_dir}/retention", "${backup_dir}/dump"]:
    ensure => directory,
  }

  file {'/usr/local/bin/mongodb-backup.sh':
    ensure  => file,
    content => template('backup/mongodb-backup.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0500',
  }
  cron {'mongodb backup':
    command => '/usr/local/bin/mongodb-backup.sh 2>&1 | logger -t mongodb-backup',
    user    => 'root',
    minute  => '0',
    hour    => '3',
  }
}
