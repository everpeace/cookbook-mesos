#
# Cookbook Name:: mesos
# Spec:: master
#

require 'spec_helper'

describe 'mesos::master' do
  deploy_dir = '/usr/local/var/mesos/deploy'

  context 'when node[:mesos][:master][:zk] is not set' do
    let(:chef_run) { ChefSpec::ServerRunner.new.converge described_recipe }

    it 'exits the Chef run' do
      expect { chef_run }.to raise_error.with_message(
        'node[:mesos][:master][:zk] is required to configure mesos-master.'
      )
    end
  end

  context 'when node[:mesos][:master][:zk] is set, but node[:mesos][:master][:zk] is not set' do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:master][:zk] = 'zk-string'
      end.converge described_recipe
    end

    it 'exits the Chef run' do
      expect { chef_run }.to raise_error.with_message(
        'node[:mesos][:master][:quorum] is required to configure mesos-master.'
      )
    end
  end

  context(
    'when node[:mesos][:master][:zk] & node[:mesos][:master][:quorum] are set, ' \
    'but all other attributes are default, on Ubuntu 14.04'
  ) do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:master][:zk] = 'zk-string'
        node.set[:mesos][:master][:quorum] = '1'
      end.converge described_recipe
    end

    it 'includes mesos::default' do
      expect(chef_run).to include_recipe 'mesos::default'
    end

    it 'does nothing to service[mesos-master]' do
      resource = chef_run.service 'mesos-master'
      expect(resource).to do_nothing
    end

    it 'creates the Mesos deploy dir' do
      expect(chef_run).to create_directory(deploy_dir).with(
        recursive: true
      )
    end

    it 'creates the masters config file' do
      expect(chef_run).to create_template "#{deploy_dir}/masters"
    end

    it 'creates the slaves config file' do
      expect(chef_run).to create_template "#{deploy_dir}/slaves"
    end

    describe 'deploy env file' do
      it 'creates it' do
        expect(chef_run).to create_template "#{deploy_dir}/mesos-deploy-env.sh"
      end

      it 'contains SSH_OPTS variable' do
        expect(chef_run).to render_file("#{deploy_dir}/mesos-deploy-env.sh")
          .with_content(/^export SSH_OPTS="#{Regexp.escape('-o StrictHostKeyChecking=no -o ConnectTimeout=2')}"$/)
      end

      it 'contains DEPLOY_WITH_SUDO variable' do
        expect(chef_run).to render_file("#{deploy_dir}/mesos-deploy-env.sh")
          .with_content(/^export DEPLOY_WITH_SUDO="1"$/)
      end
    end

    describe 'master env file' do
      it 'creates it' do
        expect(chef_run).to create_template "#{deploy_dir}/mesos-master-env.sh"
      end

      it 'contains the ' do
        expect(chef_run).to render_file("#{deploy_dir}/mesos-master-env.sh")
          .with_content(%r{^export MESOS_work_dir=/tmp/mesos$})
      end

      it 'notifies service[mesos-master] to reload configurations and restart' do
        conf = chef_run.template("#{deploy_dir}/mesos-master-env.sh")
        expect(conf).to notify('service[mesos-master]').to(:reload)
        expect(conf).to notify('service[mesos-master]').to(:restart)
      end
    end

    describe 'mesos-master upstart script' do
      it 'installs it to /etc/init' do
        expect(chef_run).to create_template '/etc/init/mesos-master.conf'
      end

      it 'describe service name "mesos master"' do
        expect(chef_run).to render_file('/etc/init/mesos-master.conf')
          .with_content(/^description "mesos master"$/)
      end

      it 'contains "start on stopped rc with runlevel 2,3,4,5"' do
        expect(chef_run).to render_file('/etc/init/mesos-master.conf')
          .with_content(/^start on stopped rc RUNLEVEL=\[2345\]$/)
      end

      it 'contains "respawn"' do
        expect(chef_run).to render_file('/etc/init/mesos-master.conf')
          .with_content(/^respawn/)
      end

      it 'specifies the correct role' do
        expect(chef_run).to render_file('/etc/init/mesos-master.conf')
          .with_content 'role=master'
      end

      it 'notifies service[mesos-master] to reload service configuration' do
        conf = chef_run.template('/etc/init/mesos-master.conf')
        expect(conf).to notify('service[mesos-master]').to(:reload).delayed
      end
    end
  end

  context 'when master and slave IPs are specified in attributes' do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        # These attributes are set to avoid failing the Chef run
        node.set[:mesos][:master][:zk] = 'zk-string'
        node.set[:mesos][:master][:quorum] = '1'
        node.set[:mesos][:master_ips] = %w(10.0.0.1)
        node.set[:mesos][:slave_ips] = %w(10.0.0.4)
      end.converge described_recipe
    end

    it 'has a masters config with supplied IPs' do
      expect(chef_run).to render_file("#{deploy_dir}/masters")
        .with_content %r{^10.0.0.1$}
    end

    it 'has a slaves config with supplied IPs' do
      expect(chef_run).to render_file("#{deploy_dir}/slaves")
        .with_content %r{^10.0.0.4$}
    end
  end

  context 'when node[:mesos][:type] == mesosphere, on Ubuntu 14.04' do
    let :chef_run do
      ChefSpec::ServerRunner.new do |node|
        node.set[:mesos][:type] = 'mesosphere'
        node.set[:mesos][:master][:zk] = 'zk-string'
        node.set[:mesos][:master][:quorum] = '1'
        node.set[:mesos][:master][:fake_key] = 'fake_value'
      end.converge(described_recipe)
    end

    it 'has a mesos-master upstart script with a different command' do
      expect(chef_run).to render_file('/etc/init/mesos-master.conf')
        .with_content(%r{^exec \/usr\/bin\/mesos-init-wrapper master$})
    end

    describe '/etc/mesos/zk' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/mesos/zk'
      end

      it 'contains configured zk string' do
        expect(chef_run).to render_file('/etc/mesos/zk').with_content(/^zk-string$/)
      end
    end

    describe '/etc/default/mesos' do
      it 'creates it' do
        expect(chef_run).to create_template('/etc/default/mesos')
      end

      it 'contains LOGS variable' do
        expect(chef_run).to render_file('/etc/default/mesos').with_content(/^LOGS=\/var\/log\/mesos$/)
      end
    end

    describe '/etc/default/mesos-master' do
      it 'creates it' do
        expect(chef_run).to create_template '/etc/default/mesos-master'
      end

      it 'contains PORT variable' do
        expect(chef_run).to render_file('/etc/default/mesos-master')
          .with_content(/^PORT=5050$/)
      end
    end

    it 'creates /etc/mesos-master' do
      expect(chef_run).to create_directory '/etc/mesos-master'
    end

    it 'deletes the contents of /etc/mesos-master' do
      expect(chef_run).to run_execute('rm -rf /etc/mesos-master/*')
    end

    describe 'configuration files in /etc/mesos-master' do
      it 'sets the content of the file matching a key in node[:mesos][:master] to its corresponding value' do
        expect(chef_run).to render_file('/etc/mesos-master/quorum')
          .with_content(/^1$/)

        expect(chef_run).to render_file('/etc/mesos-master/work_dir')
          .with_content '/tmp/mesos'

        expect(chef_run).to render_file('/etc/mesos-master/fake_key')
          .with_content(/^fake_value$/)
      end
    end
  end
end
