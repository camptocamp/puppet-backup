class backup::ldap(
  $backup_dir  = '/var/backups/ldap',
  $cron_hour   = 2,
  $cron_minute = 0,
) {
  validate_absolute_path($backup_dir)

  file { $backup_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/usr/local/bin/ldap-backup.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('backup/ldap-backup.sh.erb'),
  } ->
  cron { 'ldap-backup':
    ensure  => present,
    command => '/usr/local/bin/ldap-backup.sh',
    hour    => $cron_hour,
    minute  => $cron_minute,
  }
}
