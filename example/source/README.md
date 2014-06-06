README
====
This is a vagrant sample using mesos cookbook with `node[:mesos][:type]='source'`. This configuration will set up mesos with standalone mode.

Prerequisites
----
* VirtualBox: <https://www.virtualbox.org/>
* vagrant 1.5.2+: <http://www.vagrantup.com/>
* vagrant plugins
    * [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
          `$ vagrant plugin install vagrant-omnibus`
    * [vagrant-berkshelf](https://github.com/berkshelf/vagrant-berkshelf)
          `$ vagrant plugin install vagrant-berkshelf --plugin-version '>= 2.0.1'`
    * [vagrant-hosts](https://github.com/adrienthebo/vagrant-hosts)
          `$ vagrant plugin install vagrant-hosts`
    * [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)(optional)
          `$ vagrant plugin install vagrant-cachier`

Usage
----
### Setup a Mesos Virtual Box

    $ vagrant up

If everything went well, you can see mesos web UI on: <http://192.168.33.10:5050>
