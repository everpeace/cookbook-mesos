# encoding: utf-8

shared_examples_for 'an installation from source' do
  it 'includes build-essential recipe' do
    expect(chef_run).to include_recipe 'build-essential'
  end

  it 'includes java recipe' do
    expect(chef_run).to include_recipe 'java'
  end

  it 'includes python recipe' do
    expect(chef_run).to include_recipe 'python'
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
    expect(chef_run).to create_remote_file(File.join(Chef::Config[:file_cache_path], 'mesos-0.15.0.zip'))
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
end
