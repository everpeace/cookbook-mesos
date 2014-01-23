# encoding: utf-8

shared_examples_for 'an installation from mesosphere' do |opt|
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

  if(opt[:with_zookeeper])
    context 'with zookeeper' do
      it 'installs zookeeper, zookeeperd, zookeeper-bin' do
        ['zookeeper', 'zookeeperd', 'zookeeper-bin'].each do |zk|
          expect(package(zk)).to be_installed
        end
      end

      describe service('zookeeper') do
        it { should be_running }
      end
    end
  end

  it 'installs mesos package' do
    expect(package('mesos')).to be_installed
  end
end
