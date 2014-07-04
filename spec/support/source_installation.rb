# encoding: utf-8

shared_examples_for 'an installation from source' do |opt|
  it 'includes build-essential recipe' do
    expect(chef_run).to include_recipe 'build-essential'
  end

  it 'includes java recipe' do
    expect(chef_run).to include_recipe 'java'
  end

  it 'includes python recipe' do
    expect(chef_run).to include_recipe 'python'
  end

  it 'includes maven recipe' do
    expect(chef_run).to include_recipe 'maven'
  end

  it 'includes build_from_source recipe' do
    expect(chef_run).to include_recipe 'mesos::build_from_source'
  end

  describe 'package dependencies' do
    %w[unzip libtool libltdl-dev autoconf automake libcurl3 libcurl3-gnutls libcurl4-openssl-dev python-dev libsasl2-dev].each do |pkg_name|
      it "installs #{pkg_name}" do
        expect(chef_run).to install_package pkg_name
      end
    end
  end

  it 'downloads mesos zip' do
    expect(chef_run).to create_remote_file(File.join(Chef::Config[:file_cache_path], 'mesos-0.19.0.zip'))
  end

  it 'runs bash script for extracting mesos to home location' do
    expect(chef_run).to run_bash('extracting mesos to /opt').with_cwd('/opt')
  end

  it 'builds mesos from source' do
    expect(chef_run).to run_bash('building mesos from source').with_cwd('/opt/mesos')
    expect(chef_run).to run_bash('building mesos from source').with_code(/\.\/bootstrap/)
    expect(chef_run).to run_bash('building mesos from source').with_code(/configure --prefix=\/usr\/local/)
    expect(chef_run).to run_bash('building mesos from source').with_code(/make/)
  end

  it 'runs mesos tests' do
    expect(chef_run).to run_bash('testing mesos')
  end

  it 'installs mesos to prefix location' do
    expect(chef_run).to run_bash('install mesos to /usr/local').with_cwd('/opt/mesos/build')
    expect(chef_run).to run_bash('install mesos to /usr/local').with_code(/make install/)
    expect(chef_run).to run_bash('install mesos to /usr/local').with_code(/ldconfig/)
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

    it 'contains "/usr/local" as prefix' do
      expect(chef_run).to render_file('/etc/init/mesos-master.conf')
        .with_content(/^  prefix=\/usr\/local$/)
    end

    it 'contains "master" as role' do
      expect(chef_run).to render_file('/etc/init/mesos-master.conf')
        .with_content(/^  role=master /)
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

    it 'contains "/usr/local" as prefix' do
      expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
        .with_content(/^  prefix=\/usr\/local$/)
    end

    it 'contains "slave" as role' do
      expect(chef_run).to render_file('/etc/init/mesos-slave.conf')
        .with_content(/^  role=slave /)
    end

    it 'notifies service[mesos-slave] to reload service configuration' do
      conf = chef_run.template('/etc/init/mesos-slave.conf')
      expect(conf).to notify('service[mesos-slave]').to(:reload).delayed
    end
  end
end
