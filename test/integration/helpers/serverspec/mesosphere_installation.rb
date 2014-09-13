# encoding: utf-8

shared_examples_for 'an installation from mesosphere' do |opt|
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
