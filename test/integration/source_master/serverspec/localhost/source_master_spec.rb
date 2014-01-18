# encoding: utf-8

require 'spec_helper'

describe 'mesos::master' do
  it_behaves_like 'an installation from source'

  it_behaves_like 'a configuration of a master node'

  context 'running mesos-master' do
    let :log_file do
      file '/var/log/mesos/mesos-master.INFO'
    end

    before do
      # This is such a hack, but hey, it makes it
      # possible to actually verify something.
      backend.run_command 'mesos-master --log_dir=/var/log/mesos > /dev/null 2>&1 & sleep 1 && killall mesos-master'
    end

    it 'logs messages about starting' do
      expect(log_file.content).to match /Starting Mesos master/
      expect(log_file.content).to match /Master started on 127.0.1.1:5050/
    end

    it 'logs message about electing itself as master' do
      expect(log_file.content).to match /Elected as master/
    end
  end
end
