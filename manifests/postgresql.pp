# == Class: backup::postgresql
#
# This class provides a way to set up backup for a postgresql cluster.
# It will add a shell script based on the utility pg_dump to make
# consitent backups each nights.
#
# You must have declared the `postgresql` class before you use
# this class.
#
# === Parameters
#
# [*ensure*]
#   Enable or not the backup.
#   Defaults to "present"
#   "absent" will remove cronjob and script.
#   "purged" will remove the backup directory !
#
# [*backup_dir*]
#   The directory to use for backups.
#   Defaults to /var/backups/pgsql.
#
# [*backup_format*]
#   The backup format to use.
#   Defaults to plain.
#
# [*user*]
#   The user to use to perform the backup.
#   Defaults to postgres.
#
# [*databases*]
#   List of databases to dump.
#   If not defined (an empty array), all databases are dumped
#
# === Examples
#
#   include profiles_common::os::backup::postgresql
#
class backup::postgresql (
  $ensure        = present,
  $backup_dir    = '/var/backups/pgsql',
  $backup_format = 'plain',
  $user          = 'postgres',
  $databases     = [],
  $cron_hour     = 2,
  $cron_minute   = 0,
) {

  validate_absolute_path($backup_dir)
  validate_re(
    $ensure,
    ['^present$', '^absent$', '^purged$'],
    "Unknown value ${ensure} for ${name}"
  )
  validate_array($databases)

  file {$backup_dir:
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => [Package['postgresql-server']],
  }

  case $ensure {
    'present': {
      File[$backup_dir] {
        ensure => directory,
      }
      $cron_ensure = $ensure
      $script_ensure = $ensure
    }
    'absent': {
      File[$backup_dir] {
        ensure => directory,
      }
      $cron_ensure = $ensure
      $script_ensure = $ensure
    }
    'purged': {
      File[$backup_dir] {
        ensure  => absent,
        force   => true,
        recurse => true,
        backup  => false,
      }
      $cron_ensure = 'absent'
      $script_ensure = 'absent'
    }
    default: { fail "Unknown value ${ensure} for ${name}" }
  }

  file { '/usr/local/bin/pgsql-backup.sh':
    ensure  => $script_ensure,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('backup/pgsql-backup.sh.erb'),
    require => File[$backup_dir],
  }

  cron { 'pgsql-backup':
    ensure  => $cron_ensure,
    command => '/usr/local/bin/pgsql-backup.sh',
    user    => $user,
    hour    => $cron_hour,
    minute  => $cron_minute,
    require => [File['/usr/local/bin/pgsql-backup.sh']],
  }

}

