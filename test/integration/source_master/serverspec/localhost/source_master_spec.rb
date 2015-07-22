# encoding: utf-8

require 'spec_helper'

describe 'mesos::master' do
  it_behaves_like 'an installation from source'

  it_behaves_like 'a master node'

  context 'master upstart script' do
    describe file '/etc/init/mesos-master.conf' do
      describe '#content' do
        subject { super().content }
        it { is_expected.to include 'role=master' }
      end
    end
  end
end
