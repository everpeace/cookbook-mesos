# encoding: utf-8

shared_examples_for 'an installation from mesosphere' do
  let :mesos_deb do
    chef_run.remote_file(File.join(Chef::Config[:file_cache_path], 'mesos_0.15.0.deb'))
  end

  it 'installs default-jre-headless' do
    expect(chef_run).to install_apt_package 'default-jre-headless'
  end

  it 'installs libcurl3' do
    expect(chef_run).to install_package 'libcurl3'
  end

  describe 'workaround symlink for libjvm.so' do
    context 'when /usr/lib/libjvm.so is already a symlink' do
      before do
        stub_command("test -L /usr/lib/libjvm.so").and_return(true)
      end

      it 'does nothing' do
        expect(chef_run).not_to create_link '/usr/lib/libjvm.so'
      end
    end

    context 'when /usr/lib/libjvm.so is not a symlink' do
      it 'creates a symlink' do
        expect(chef_run).to create_link('/usr/lib/libjvm.so').with(to: '/usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so')
      end
    end
  end

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

  it 'downloads mesos deb' do
    expect(chef_run).to create_remote_file File.join(Chef::Config[:file_cache_path], 'mesos_0.15.0.deb')
  end

  it 'notifies installation of mesos package using dpkg' do
    expect(mesos_deb).to notify('dpkg_package[mesos]').to(:install).delayed
  end

  it 'also runs `install` action using dpkg' do
    expect(chef_run).to install_dpkg_package 'mesos'
  end

  it 'creates /etc/default/mesos' do
    expect(chef_run).to create_template '/etc/default/mesos'
  end
end
