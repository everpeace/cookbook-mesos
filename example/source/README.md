README
====
This is a vagrant sample using mesos cookbook with `node[:mesos][:type]='source'`. This configuration will set up mesos with standalone mode.

Prerequisites
----
* VirtualBox: <https://www.virtualbox.org/>
* vagrant 1.2+: <http://www.vagrantup.com/>
* vagrant plugins
    * [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
          `$ vagrant plugin install vagrant-omnibus`
    * [vagrant-berkshelf](https://github.com/RiotGames/vagrant-berkshelf)
          `$ vagrant plugin install vagrant-berkshelf`
    * [vagrant-hosts](https://github.com/adrienthebo/vagrant-hosts)
          `$ vagrant plugin install vagrant-hosts`
    * [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)(optional)
          `$ vagrant plugin install vagrant-cachier`

Usage
----
### Setup a Mesos Virtual Box

    $ vagrant up

### Mesos cluster in single node.
just hit below command.

    $ vagrant ssh -c 'mesos-start-cluster.sh'

If everything went well, you can see mesos web UI on: <http://localhost:5050>

when stop, just hit
    
    $ vagrant ssh -c 'mesos-stop-cluster.sh'
    