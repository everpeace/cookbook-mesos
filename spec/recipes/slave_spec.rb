#
# Cookbook Name:: mesos
# Spec:: slave
#

require 'spec_helper'

describe 'mesos::slave' do
  deploy_dir = '/usr/local/var/mesos/deploy'

  context 'when node[:mesos][:slave][:master] is not set' do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    it 'exits the Chef run' do
      expect { chef_run }.to raise_error.with_message(
        'node[:mesos][:slave][:master] is required to configure mesos-slave.'
      )
    end
  end

  context(
    'when node[:mesos][:slave][:master] is set, ' \
    'but all other attributes are default, on Ubuntu 14.04'
  ) do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:slave][:master] = 'test-master'
      end.converge described_recipe
    end

    it 'includes mesos::default' do
      expect(chef_run).to include_recipe 'mesos::default'
    end

    it 'does nothing to service[mesos-slave]' do
      resource = chef_run.service 'mesos-slave'
      expect(resource).to do_nothing
    end

    it 'creates the Mesos deploy dir' do
      expect(chef_run).to create_directory(deploy_dir).with(
        recursive: true
      )
    end

    describe 'slave env file' do
      it 'creates it' do
        expect(chef_run).to create_template "#{deploy_dir}/mesos-slave-env.sh"
      end

      it 'notifies service[mesos-slave] to reload configurations and restart' do
        conf = chef_run.template("#{deploy_dir}/mesos-slave-env.sh")
        expect(conf).to notify('service[mesos-slave]').to(:reload).delayed
        expect(conf).to notify('service[mesos-slave]').to(:restart).delayed
      end
    end

    describe 'mesos-slave upstart script' do
      it 'installs it to /etc/init' do
        expect(chef_run).to create_template '/etc/init/mesos-slave.conf'
      end

      it 'describe service name "mesos slave"' do
        expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
          .with_content 'description "mesos slave"'
      end

      it 'contains start on stopped rc with runlevel 2,3,4,5' do
        expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
          .with_content 'start on stopped rc RUNLEVEL=[2345]'
      end

      it 'contains respawn' do
        expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
          .with_content 'respawn'
      end

      it 'sets the correct role' do
        expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
          .with_content 'role=slave'
      end

      it 'notifies service[mesos-slave] to reload service configuration' do
        conf = chef_run.template('/etc/init/mesos-slave.conf')
        expect(conf).to notify('service[mesos-slave]').to(:reload).delayed
      end
    end
  end

  context 'when node[:mesos][:type] == mesosphere, on Ubuntu 14.04' do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:type] = 'mesosphere'
        node.set[:mesos][:slave][:master] = 'test-master'
        node.set[:mesos][:slave][:slave_key] = 'slave_value'
        node.set[:mesos][:slave][:attributes][:rackid] = 'us-east-1b'
      end.converge(described_recipe)
    end

    it 'has a slave env file with each key-value pair from node[:mesos][:slave]' do
      expect(chef_run).to render_file("#{deploy_dir}/mesos-slave-env.sh")
        .with_content 'export MESOS_slave_key=slave_value'
    end

    it 'has a mesos-slave upstart script with a different command' do
      expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
        .with_content 'exec /usr/bin/mesos-init-wrapper slave'
    end

    describe '/etc/mesos/zk' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/mesos/zk'
      end

      it 'contains configured zk string' do
        expect(chef_run).to render_file('/etc/mesos/zk').with_content 'test-master'
      end
    end

    describe '/etc/default/mesos' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/default/mesos'
      end

      it 'populates the log_dir correctly' do
        expect(chef_run).to render_file('/etc/default/mesos')
          .with_content 'LOGS=/var/log/mesos'
      end
    end

    describe '/etc/default/mesos-slave' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/default/mesos-slave'
      end

      it 'contains ISOLATION variable' do
        expect(chef_run).to render_file('/etc/default/mesos-slave')
          .with_content %r{^ISOLATION=cgroups/cpu,cgroups/mem$}
      end
    end

    it 'creates /etc/mesos-slave' do
      expect(chef_run).to create_directory('/etc/mesos-slave').with(
        recursive: true
      )
    end

    it 'removes the contents of /etc/mesos-slave dir' do
      expect(chef_run).to run_execute 'rm -rf /etc/mesos-slave/*'
    end

    describe 'configuration files in /etc/mesos-slave' do
      it 'sets the content of the file matching a key in node[:mesos][:slave] to its corresponding value' do
        expect(chef_run).to render_file('/etc/mesos-slave/work_dir')
          .with_content '/tmp/mesos'

        expect(chef_run).to render_file('/etc/mesos-slave/slave_key')
          .with_content 'slave_value'

        expect(chef_run).to create_directory '/etc/mesos-slave/attributes'

        expect(chef_run).to render_file('/etc/mesos-slave/attributes/rackid')
          .with_content 'us-east-1b'
      end
    end
  end
end
