# encoding: utf-8

require 'spec_helper'

describe 'mesos::slave' do
  it_behaves_like 'an installation from source'

  it_behaves_like 'a slave node'

  context 'slave upstart script' do
    describe file '/etc/init/mesos-slave.conf' do
      describe '#content' do
        subject { super().content }
        it { is_expected.to include 'role=slave' }
      end
    end
  end
end
