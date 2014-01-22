# encoding: utf-8

shared_context 'setup context' do
  before do
    File.stub(:exist?).and_call_original
    File.stub(:exist?).with('/usr/local/sbin/mesos-master').and_return(false)
    File.stub(:exists?).and_call_original
    File.stub(:exists?).with('/usr/local/sbin/mesos-master').and_return(false)

    stub_command('test -L /usr/lib/libjvm.so')
    stub_command("update-alternatives --display java | grep '/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java - priority 1061'")
    stub_command("/usr/bin/python -c 'import setuptools'")
  end
end
