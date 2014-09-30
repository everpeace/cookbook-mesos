# Mesos Cookbook [![Build Status](https://travis-ci.org/everpeace/cookbook-mesos.png?branch=master)](https://travis-ci.org/everpeace/cookbook-mesos)

Install Mesos (<http://mesos.apache.org/>) and configure mesos master and slave.
This cookbook also supports installation by both bulding from source and with [Mesosphere](http://mesosphere.io) package.
You can switch installation type using the `node[:mesos][:type]` attribute (`source` or `mesosphere`).

## Platform

Currently only supports `ubuntu` and `centos`.  But `centos` support is  experimental.

If you would use `cgroups` isolator or `docker` containerizer, version 14.04 is highly recommended. Note that `docker` containerizer is only supported by Mesos 0.20.0+.

## Installation Type

You have to specify intallation type (`source` or `mesosphere`) by setting `node[:mesos][:type]` variable.

Currently this cookbook defaults to build mesos from source, i.e.
`node[:mesos][:type]` is set to `source`.

## Recipes

### mesos::default

Install mesos using `build_from_source` recipe or `mesosphere` recipe, depending
on what the `node[:mesos][:type]` attribute is set to (`source` or `mesosphere`).

### mesos::build\_from\_source

Install mesos (download zip from [github](https://github.com/apache/mesos), configure, make, make install).

### mesos::mesosphere

Install mesos using Mesosphere's mesos package.
You can also install zookeeper package by `node[:mesos][:mesosphere][:with_zookeeper]` if required because Mesosphere's mesos package doesn't include zookeeper.  You can also specify mesosphere package's build version (see below for details).

### mesos::master

Configure master and cluster deployment configuration files, and start
`mesos-master`.

* `node[:mesos][:prefix]/var/mesos/deploy/masters`
* `node[:mesos][:prefix]/var/mesos/deploy/slaves`
* `node[:mesos][:prefix]/var/mesos/deploy/mesos-deploy-env.sh`
* `node[:mesos][:prefix]/var/mesos/deploy/mesos-master-env.sh`

If you choose `mesosphere` as `node[:mesos][:type]`, the `node[:mesos][:prefix]` attribute
will be overridden to `/usr/local`, which is because the package from Mesosphere
installs mesos into that directory.

Furthermore, this recipe will also configure upstart configuration files.

* `/etc/mesos/zk`
* `/etc/defaults/mesos`
* `/etc/defaults/mesos-master`

#### How to configure `mesos-master`

You can configure `mesos-master` command line options using the `node[:mesos][:master]` attribute.

If you have a configuration as shown below:

```
node[:mesos][:master] = {
  :port    => "5050",
  :log_dir => "/var/log/mesos",
  :zk      => "zk://localhost:2181/mesos",
  :cluster => "MyCluster",
  :quorum  => "1"
}
```

Then `mesos-master` will be invoked with command line options like this:

```
mesos-master --zk=zk://localhost:2181/mesos --port=5050 --log_dir=/var/log/mesos --cluster=MyCluster
```

See [here](http://mesos.apache.org/documentation/latest/configuration/) for available options or the output of `mesos-master --help`.

### mesos::slave

Configure slave configuration files, and start `mesos-slave`.

* `node[:mesos][:prefix]/var/mesos/deploy/mesos-slave-env.sh`

If you choose `mesosphere` as `node[:mesos][:type]`, the `node[:mesos][:prefix]` attribute
will be overridden to `/usr/local`, which is because the package from Mesosphere
installs mesos into that directory by default.

Furthermore, this recipe also configures upstart configuration files.

* `/etc/mesos/zk`
* `/etc/defaults/mesos`
* `/etc/defaults/mesos-slave`

#### How to configure `mesos-slave`

You can configure `mesos-slave` command line options by `node[:mesos][:slave]` hash.
If you have a configuration as shown below:

```
node[:mesos][:slave] = {
  :master    => "zk://localhost:2181/mesos",
  :log_dir   => "/var/log/mesos",
  :containerizers => "docker,mesos",
  :isolation => "cgroups/cpu,cgroups/mem",
  :work_dir  => "/var/run/work"
}
```

Then `mesos-slave` will be invoked with command line options like this:

```
mesos-slave --master=zk://localhost:2181/mesos --log_dir=/var/log/mesos --containerizers=docker,mesos --isolation=cgroups/cpu,cgroups/mem --work_dir=/var/run/work
```

See [here](http://mesos.apache.org/documentation/latest/configuration/) for available options or the output of `mesos-slave --help`.

### [Deprecated] mesos::docker-executor

Install [mesos-docker executor](https://github.com/mesosphere/mesos-docker).
Currently only Mesos 0.14.0 is supported.

__NOTE__: This cookbook DOES NOT install `docker` automatically.
So, you need to install docker manually.
See [./example/mesosphere/Vagrantfile](https://github.com/everpeace/cookbook-mesos/tree/master/example/mesosphere/Vagrantfile)

## Usage

Please see below:

* [everpeace/vagrant-mesos](https://github.com/everpeace/vagrant-mesos)
* [./example/source](https://github.com/everpeace/cookbook-mesos/tree/master/example/source/)
* [./example/mesosphere](https://github.com/everpeace/cookbook-mesos/tree/master/example/mesosphere/)

## Attributes

### mesos::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:mesos][:type]</tt></td>
    <td>String</td>
    <td>installation type(<tt>source</tt> or <tt>mesosphere</tt>)</td>
    <td><tt>source</tt></td>
  </tr>
</table>

### mesos::build\_from\_source

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:mesos][:version]</tt></td>
    <td>String</td>
    <td>Version(branch or tag name at http://github.com/apache/mesos).</td>
    <td><tt>0.20.1</tt></td>
  </tr>
  <tr>
  <td><tt>[:mesos][:prefix]</tt></td>
  <td>String</td>
  <td>Prefix value to be passed to configure script</td>
  <td><tt>/usr/local</tt></td>
  </tr>
  <tr>
  <td><tt>[:mesos][:home]</tt></td>
  <td>String</td>
  <td>Directory which mesos sources are extracted to(<tt>node[:mesos][:home]/mesos</tt>).</td>
  <td><tt>/opt</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:build][:skip_test]</tt></td>
    <td>Boolean</td>
    <td>Flag whether test will be performed.</td>
    <td><tt>true</tt></td>
  </tr>
</table>

### mesos::mesosphere

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:mesos][:version]</tt></td>
    <td>String</td>
    <td>Version.(see http://mesosphere.io/downloads/)</td>
    <td><tt>0.20.1</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:mesosphere][:build_version]</tt></td>
    <td>String</td>
    <td>build version of mesosphere package.  mesosphere's package version consists of 2 parts, `<mesos_version>-<build_version>`, for example `0.20.0-1.0.ubuntu1404`</td>
    <td><tt>1.0.ubuntu1404</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:mesosphere][:with_zookeeper]</tt></td>
    <td>String</td>
    <td>flag for installing zookeeper package</td>
    <td><tt>false</tt></td>
  </tr>
</table>

### mesos::master

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:mesos][:prefix]</tt></td>
    <td>String</td>
    <td> Prefix value to be passed to configure script.  This value will be overridden by <tt>/usr/local</tt> when you choose <tt>mesosphere</tt>.</td>
    <td><tt>/usr/local</tt><br/></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:ssh_opt]</tt></td>
    <td>String</td>
    <td>ssh options to be used in <tt>mesos-[start|stop]-cluster</tt></td>
    <td><tt>-o StrictHostKeyChecking=no <br/> -o ConnectTimeout=2</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:deploy_with_sudo]</tt></td>
    <td>String</td>
    <td>Flag whether sudo will be used in <tt>mesos-[start|stop]-cluster</tt></td>
    <td><tt>1</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:cluster_name]</tt></td>
    <td>String</td>
    <td>[OBSOLETE] Human readable name for the cluster, displayed at webui. </td>
    <td><tt>MyCluster</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:mater_ips]</tt></td>
    <td>Array of String</td>
    <td>IP list of masters used in <tt>mesos-[start|stop]-cluster</tt></td>
    <td>[ ]</td>
  </tr>
  <tr>
    <td><tt>[:mesos][:slave_ips]</tt></td>
    <td>Array of String</td>
    <td>IP list of slaves used in <tt>mesos-[start|stop]-cluster</tt></td>
    <td>[ ]</td>
  </tr>
  <tr>
    <td><tt>[:mesos][:master][:zk]</tt></td>
    <td>String</td>
    <td>[REQUIRED(0.19.1+)] ZooKeeper URL (used for leader election amongst masters). May be one of:<br/>                                             zk://host1:port1,host2:port2,.../path<br/>
 zk://username:password@host1:port1,host2:port2,.../path<br />
 file://path/to/file (where file contains one of the above)</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:master][:work_dir]</tt></td>
    <td>String</td>
    <td>[REQUIRED(0.19.1+)] Where to store the persistent information stored in the Registry.</td>
    <td><tt>/tmp/mesos</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:master][:quorum]</tt></td>
    <td>String</td>
    <td>[REQUIRED(0.19.1+)] The size of the quorum of replicas when using 'replicated_log' based
                                           registry. It is imperative to set this value to be a majority of
                                           masters i.e., quorum > (number of masters)/2.</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:master][:&lt;option_name&gt;]</tt></td>
    <td>String</td>
    <td>You can set arbitrary command line option for <tt>mesos-master</tt>. See [here](http://mesos.apache.org/documentation/latest/configuration/) for available options or the output of `mesos-master --help`.</td>
    <td></td>
  </tr>
</table>

### mesos::slave

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:mesos][:prefix]</tt></td>
    <td>String</td>
    <td>Prefix value to be passed to configure script.  This value will be overridden by <tt>/usr/local</tt> when you choose <tt>mesosphere</tt>.</td>
    <td><tt>/usr/local</tt></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:slave][:master]</tt></td>
    <td>String</td>
    <td>[REQUIRED] mesos master url.This should be ip:port for non-ZooKeeper based masters, otherwise a zk:// . when <tt>mesosphere</tt>, you should set zk:// address. </td>
    <td></td>
  </tr>
  <tr>
    <td><tt>[:mesos][:slave][:&lt;option_name&gt;]</tt></td>
    <td>String</td>
    <td>You can set arbitrary command line option for <tt>mesos-slave</tt>. See [here](http://mesos.apache.org/documentation/latest/configuration/) for available options or the output of `mesos-slave --help`.</td>
    <td></td>
  </tr>
</table>

## Testing

There are a couple of test suites

* `chefspec` for unit tests.
* `test-kitchen` with `serverspec` for integration tests (using `vagrant`).

in place, which tests both source and mesosphere installations (as well as master and slave recipes).

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
