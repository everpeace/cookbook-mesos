# encoding: utf-8

shared_examples_for 'an installation from mesosphere' do |opt|
  if(opt[:with_zookeeper])
    context 'with zookeeper' do
      it 'installs Zookeeper packages' do
        puts "The OS family is #{os[:family]}"
        case os[:family]
        when 'centos', 'redhat'
          pkgs = %w(zookeeper zookeeper-server)
        when 'ubuntu', 'debian'
          pkgs = %(zookeeper zookeeperd zookeeper-bin)
        end

        pkgs.each do |zk|
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
