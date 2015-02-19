class backup::duplicity_s3 (
  $bucket_name,
  $access_key,
  $secret_key,
  $gpg_key_id,
  $gpg_key_pass,
  $gpg_secring_source,
  $items,
) {

  include ::duplicity
  ensure_packages(['python-boto'])

  file {'/root/.gnupg':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file {'/root/.gnupg/secring.gpg':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => $gpg_secring_source,
  }

  create_resources ('backup::duplicity_s3_item', $items)

}
