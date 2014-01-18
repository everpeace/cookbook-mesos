# encoding: utf-8

require 'spec_helper'

describe 'mesos::slave' do
  it_behaves_like 'an installation from source'

  it_behaves_like 'a configuration of a slave node'

  describe 'attempting to run mesos-slave' do
    let :slave_command do
      command 'mesos-slave --master=127.0.0.1'
    end

    it 'attempts to start' do
      expect(slave_command).to return_stderr /Starting Mesos slave/
    end

    it 'complains about not being able to connect to a master' do
      expect(slave_command).to return_stderr /Failed to create a master detector/
    end
  end
end
