# encoding: utf-8

shared_examples_for 'an installation from mesosphere' do |opt|
  describe' with_zookeeper option' do
    it 'installs zookeeper package' do
      expect(chef_run).to install_package 'zookeeper'
    end

    it 'installs zookeeperd package' do
      expect(chef_run).to install_package 'zookeeperd'
    end

    it 'installs zookeeper-bin package' do
      expect(chef_run).to install_package 'zookeeper-bin'
    end

    it 'restart zookeeper service' do
      expect(chef_run).to restart_service 'zookeeper'
    end
  end

  it 'install mesos package' do
    expect(chef_run).to install_package 'mesos'
  end

  it 'creates /etc/default/mesos' do
    expect(chef_run).to create_template '/etc/default/mesos'
  end

  describe 'mesos-master upstart script' do
    it 'installs it to /etc/init' do
      expect(chef_run).to create_template '/etc/init/mesos-master.conf'
    end

    it 'describe service name "mesos master"' do
      expect(chef_run).to render_file('/etc/init/mesos-master.conf')
        .with_content(/^description "mesos master"$/)
    end

    it "contains \"#{opt[:init_master_state]} on stopped rc with runlevel 2,3,4,5\"" do
      expect(chef_run).to render_file('/etc/init/mesos-master.conf')
        .with_content(/^#{opt[:init_master_state]} on stopped rc RUNLEVEL=\[2345\]$/)
    end

    it 'contains "respawn"' do
      expect(chef_run).to render_file('/etc/init/mesos-master.conf')
        .with_content(/^respawn/)
    end

    it 'contains "exec /usr/bin/mesos-init-wrapper master"' do
      expect(chef_run).to render_file('/etc/init/mesos-master.conf')
        .with_content(/^exec \/usr\/bin\/mesos-init-wrapper master$/)
    end

    it 'notifies service[mesos-master] to reload service configuration' do
      conf = chef_run.template('/etc/init/mesos-master.conf')
      expect(conf).to notify('service[mesos-master]').to(:reload).delayed
    end
  end

  describe 'mesos-slave upstart script' do
    it 'installs it to /etc/init' do
      expect(chef_run).to create_template '/etc/init/mesos-slave.conf'
    end

    it 'describe service name "mesos slaver"' do
      expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
        .with_content(/^description "mesos slave"$/)
    end

    it "contains #{opt[:init_slave_state]} on stopped rc with runlevel 2,3,4,5" do
      expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
        .with_content(/^#{opt[:init_slave_state]} on stopped rc RUNLEVEL=\[2345\]$/)
    end

    it 'contains respawn' do
      expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
        .with_content(/^respawn$/)
    end

    it 'contains "exec /usr/bin/mesos-init-wrapper slave"' do
      expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
        .with_content(/^exec \/usr\/bin\/mesos-init-wrapper slave$/)
    end

    it 'notifies service[mesos-slave] to reload service configuration' do
      conf = chef_run.template('/etc/init/mesos-slave.conf')
      expect(conf).to notify('service[mesos-slave]').to(:reload).delayed
    end
  end

  describe 'mesos-master service resource' do
    it 'performs no action' do
      expect(chef_run).to_not disable_service("mesos-master")
    end
  end

  describe 'mesos-slave service resource' do
    it 'performs no action' do
      expect(chef_run).to_not disable_service("mesos-slave")
    end
  end
end
