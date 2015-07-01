module Helpers
  module Mesos
    def mesos_version
      node[:mesos][:version]
    end

    def platform
      node['platform']
    end

    def platform_version
      node['platform_version']
    end
  end

  module Source extend Helpers::Mesos
    unless (const_defined?(:SOURCE_INFO))
      SOURCE_INFO = {
        'dependency_packages' => {
          # The list is necessary and sufficient?
          'ubuntu' => ["unzip", "libtool", "libltdl-dev", "autoconf", "automake", "libcurl3", "libcurl3-gnutls", "libcurl4-openssl-dev", "python-dev", "libsasl2-dev"],
          'centos' => ["python-devel", "zlib-devel", "libcurl-devel", "openssl-devel", "cyrus-sasl-devel", "cyrus-sasl-md5"]
        },
        'dependency_recipes' => {
          'ubuntu' => ["python", "build-essential", "maven"],
          'centos' => ["python", "build-essential", "maven"]
        }
      }
    end

    def prefix
      node[:mesos][:prefix]
    end

    def installed?
      cmd = "#{prefix}/mesos-master --version |cut -f 2 -d ' '"
      File.exist?("#{prefix}/mesos-master") && (`#{cmd}`.chop == mesos_version)
    end

    def download_url
      "https://github.com/apache/mesos/archive/#{mesos_version}.zip"
    end

    def include_dependency_recipes
      SOURCE_INFO['dependency_recipes'][platform].each do |r|
        include_recipe r
      end
    end

    def install_dependency_packages
      SOURCE_INFO['dependency_packages'][platform].each do |p|
        package p do
          action :install
        end
      end
    end
  end #of Module Source
end #of Module Helpers
