# encoding: utf-8

shared_context 'setup context' do
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/usr/local/sbin/mesos-master').and_return(false)
    allow(File).to receive(:exists?).and_call_original
    allow(File).to receive(:exists?).with('/usr/local/sbin/mesos-master').and_return(false)
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:exist?).with('/usr/local/var/mesos/deploy').and_return(false)
    allow(Dir).to receive(:exists?).and_call_original
    allow(Dir).to receive(:exists?).with('/usr/local/var/mesos/deploy').and_return(false)

    stub_command('test -L /usr/lib/libjvm.so')
    stub_command("update-alternatives --display java | grep '/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java - priority 1061'")
    stub_command("/usr/bin/python -c 'import setuptools'")
  end
end
