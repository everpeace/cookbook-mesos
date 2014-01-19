# encoding: utf-8

shared_examples_for 'an installation from mesosphere' do
  it 'installs default-jre-headless' do
    expect(package('default-jre-headless')).to be_installed
  end

  it 'installs libcurl3' do
    expect(package('libcurl3')).to be_installed
  end

  context 'workaround for libjvm.so issue' do
    it 'creates symlink for libjvm.so' do
      expect(file('/usr/lib/libjvm.so')).to be_linked_to '/usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so'
    end
  end

  context 'with zookeeper' do
    pending
  end

  it 'downloads mesos package to Chef cache path' do
    expect(file('/tmp/kitchen/cache/mesos_0.15.0.deb')).to be_a_file
  end

  it 'installs mesos package' do
    expect(package('mesos')).to be_installed
  end
end
