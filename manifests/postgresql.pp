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
# [*not_databases*]
#   List of databases _not_ to dump.
#   This only applies if the *databases* parameter is not set.
#
# [*hotstandby*]
#   Boolean telling we're on a hot-standby host or not.
#   Default to false.
#   More information: http://dba.stackexchange.com/a/30639
#
# [*keep_daily*]
#   Boolean telling if we keep daily dumps for one week.
#   Default to true.
#
# [*keep_monthly*]
#   Boolean telling if we keep a monthly dump on the 1st of each month.
#   Default to true.
#
# [*yearly_month*]
#   Boolean telling we want to suffix monthly backup with year.
#   Default to false.
#
# === Examples
#
#   include profiles_common::os::backup::postgresql
#
class backup::postgresql (
  $ensure        = present,
  $backup_dir    = '/var/backups/pgsql',
  $backup_format = 'plain',
  $hotstandby    = false,
  $user          = 'postgres',
  $databases     = [],
  $not_databases = [],
  $cron_hour     = 2,
  $cron_minute   = 0,
  $cron_weekday  = "*",
  $container     = undef,
  $keep_daily    = true,
  $keep_monthly  = true,
  $yearly_month  = false
) {

  validate_absolute_path($backup_dir)
  validate_re(
    $ensure,
    ['^present$', '^absent$', '^purged$'],
    "Unknown value ${ensure} for ${name}"
  )
  validate_array($databases)
  validate_array($not_databases)

  $_user = $container ? {
    undef   => $user,
    default => undef,
  }

  $require = $container ? {
    undef   => Package['postgresql-server'],
    default => undef,
  }
  file {$backup_dir:
    owner   => $_user,
    group   => $_user,
    mode    => '0755',
    require => $require,
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
    user    => $_user,
    hour    => $cron_hour,
    minute  => $cron_minute,
    weekday => $cron_weekday,
    require => [File['/usr/local/bin/pgsql-backup.sh']],
  }

}

