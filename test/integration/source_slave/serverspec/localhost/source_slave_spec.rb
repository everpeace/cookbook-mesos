# encoding: utf-8

require 'spec_helper'

describe 'mesos::slave' do
  it_behaves_like 'an installation from source'

  it_behaves_like 'a configuration of a slave node'

  describe 'running mesos-slave' do
    let :log_file do
      file '/var/log/mesos/mesos-slave.INFO'
    end

    before do
      # This is such a hack, but hey, it makes it
      # possible to actually verify something.
      backend.run_command 'mesos-master --log_dir=/var/log/mesos --ip=127.0.0.1 > /dev/null 2>&1 &'
      backend.run_command 'mesos-slave --master=127.0.0.1:5050 --log_dir=/var/log/mesos > /dev/null 2>&1 &'
      backend.run_command 'sleep 1 && killall mesos-master && killall mesos-slave'
    end

    it 'logs messages about starting and being regstered to master' do
      expect(log_file.content).to match /Starting Mesos slave/
      expect(log_file.content).to match /Registered with master/
    end
  end
end
