require 'spec_helper'

describe 'backup::postgresql' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:params) do
        {
          :container => true,
        }
      end
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/var/backups/pgsql') }
      it { 
        is_expected.to contain_file('/usr/local/bin/pgsql-backup.sh').with_content(/\$BKPDIR\/pgsql_\$MONTH.tar/)
      }
    end

    context "on #{os} with yearly_month" do

      let(:params) do
        {
          :container => true,
          :yearly_month => 'true',
        }
      end
      it { is_expected.to compile.with_all_deps }
      it { 
        is_expected.to contain_file('/usr/local/bin/pgsql-backup.sh').with_content(/\$BKPDIR\/pgsql_\${MONTH}_\${YEAR}.tar/)
      }
    end
  end
end
