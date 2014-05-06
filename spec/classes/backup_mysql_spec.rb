require 'spec_helper'

describe 'backup::mysql' do
  let(:facts) { {
    :osfamily => 'Debian',
  } }
  it { should compile.with_all_deps }
end
