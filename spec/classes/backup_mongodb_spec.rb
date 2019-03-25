require 'spec_helper'

describe 'backup::mongodb' do
  on_supported_os.each do |os, facts|
    let :params do
      {
        :mongo_version => '4.0.6',
        :mongo_admin_password => 'foobar'
      }
    end
    context "on #{os}" do
      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file('/usr/local/bin/mongodb-backup.sh').with_content(%r{/usr/bin/mongodump .* 'foobar' .*})
      }
    end
  end
end
