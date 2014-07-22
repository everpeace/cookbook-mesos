# encoding: utf-8

shared_examples_for 'an installation from source' do

  context 'installation into /usr/local' do
    shared_examples_for 'an install directory' do
      let :directory do
        file(path)
      end

      it 'is a directory' do
        expect(directory).to be_a_directory
      end

      it 'has expected permissions' do
        expect(directory).to be_mode '755'
      end

      it 'is owned by root' do
        expect(directory).to be_owned_by 'root'
      end

      it 'is managed by root group' do
        expect(directory).to be_grouped_into 'root'
      end
    end

    describe 'include directory' do
      it_behaves_like 'an install directory' do
        let :path do
          '/usr/local/include/mesos'
        end
      end
    end

    describe 'deploy directory' do
      it_behaves_like 'an install directory' do
        let :path do
          '/usr/local/var/mesos/deploy'
        end
      end
    end

    describe 'webui directory' do
      it_behaves_like 'an install directory' do
        let :path do
          '/usr/local/share/mesos/webui'
        end
      end
    end

    it 'puts library files in lib directory' do
      lib_directory_path = '/usr/local/lib'

      expect(file(File.join(lib_directory_path, 'libmesos.so'))).to be_a_file
      expect(file(File.join(lib_directory_path, 'libmesos.so'))).to be_linked_to 'libmesos-0.19.1.so'
      expect(file(File.join(lib_directory_path, 'libmesos.la'))).to be_a_file
    end

    it 'puts files in libexec directory' do
      lib_directory_path = '/usr/local/libexec/mesos'

      expect(file(File.join(lib_directory_path, 'mesos-executor'))).to be_a_file
      expect(file(File.join(lib_directory_path, 'mesos-launcher'))).to be_a_file
    end
  end

  context 'files in /usr/local/bin' do
    %w[mesos mesos-execute mesos-local mesos-log mesos-ps mesos-resolve].each do |bin_script|
      it "creates bin/#{bin_script}" do
        expect(file("/usr/local/bin/#{bin_script}")).to be_a_file
        expect(file("/usr/local/bin/#{bin_script}")).to be_owned_by('root')
        expect(file("/usr/local/bin/#{bin_script}")).to be_grouped_into('root')
        expect(file("/usr/local/bin/#{bin_script}")).to be_mode('755')
      end
    end
  end

  context 'scripts in /usr/local/sbin' do
    let :bin_directory_path do
      '/usr/local/sbin'
    end

    let :bin_directory do
      file(bin_directory_path)
    end

    let :bin_scripts do
      Dir.glob(File.join(bin_directory_path, '*'))
    end

    it 'creates the directory' do
      expect(bin_directory).to be_a_directory
    end

    it 'is not empty' do
      expect(bin_scripts).not_to be_empty
    end

    context 'each bin script' do
      let :expected_scripts do
        %w[
          mesos-daemon.sh
          mesos-master
          mesos-slave
          mesos-start-cluster.sh
          mesos-start-masters.sh
          mesos-start-slaves.sh
          mesos-stop-cluster.sh
          mesos-stop-masters.sh
          mesos-stop-slaves.sh
        ].map { |script| "/usr/local/sbin/#{script}" }
      end

      it 'exists' do
        expected_scripts.each { |script| expect(bin_scripts).to include(script) }
      end

      it 'is owned by root' do
        expected_scripts.each { |script| expect(file(script)).to be_owned_by('root') }
      end

      it 'is managed by root group' do
        expected_scripts.each { |script| expect(file(script)).to be_grouped_into('root') }
      end

      it 'has expected file permissions' do
        expected_scripts.each { |script| expect(file(script)).to be_mode('755') }
      end
    end
  end

  context 'each upstart script in /etc/init' do
    let :conf_files do
      Dir.glob(File.join('/etc/init', 'mesos-*.conf'))
    end

    let :expected_confs do
      ['mesos-master.conf','mesos-slave.conf'].map { |conf| "/etc/init/#{conf}" }
    end

    it 'exists' do
      expected_confs.each { |conf| expect(conf_files).to include(conf) }
    end

    it 'is owned by root' do
      expected_confs.each { |conf| expect(file(conf)).to be_owned_by('root') }
    end

    it 'is managed by root group' do
      expected_confs.each { |conf| expect(file(conf)).to be_grouped_into('root') }
    end

    it 'has expected file permissions' do
      expected_confs.each { |conf| expect(file(conf)).to be_mode('644') }
    end
  end
end
