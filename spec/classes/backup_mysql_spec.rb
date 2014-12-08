require 'spec_helper'

describe 'backup::mysql' do
  let(:facts) {{
    :osfamily => 'Debian',
  }}

  let(:params) do
    {
    :data_dir   => '/var/lib/mysql',
    :backup_dir => '/var/backups/mysql',
    }
  end

  it { should compile.with_all_deps }
end
