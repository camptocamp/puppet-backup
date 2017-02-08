define backup::duplicity_s3_item (
  $source,
  $ensure = present,
  $rules  = ['+ **'],
) {

  $destination = $::backup::duplicity_s3::bucket_name ? {
    /(^[a-z0-9\+]+:\/\/.*$)/ => "${::backup::duplicity_s3::bucket_name}/${name}",
    default               => "s3+http://${::backup::duplicity_s3::bucket_name}/${name}",
  }

  duplicity::backup {$name:
    ensure      => $ensure,
    source      => $source,
    rules       => $rules,
    destination => $destination,
    args        => '--s3-european-buckets --s3-use-new-style',
    env_var     => ["AWS_ACCESS_KEY_ID='${::backup::duplicity_s3::access_key}'",
                    "AWS_SECRET_ACCESS_KEY='${::backup::duplicity_s3::secret_key}'",
                    "GPG_KEY=${::backup::duplicity_s3::gpg_key_id}",
                    "PASSPHRASE=${::backup::duplicity_s3::gpg_key_pass}"],
  }
}
