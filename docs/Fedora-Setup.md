The following instructions are for fresh install of Fedora 33.
I will be running all the commands as a non-privileged user part of groups
libvirt - to allow user to create virtual machines using libvirtd
and wheel -  to allow sudo access.

Modify the steps accordingly for your setup.

Ensure the following packages are installed
> $ sudo dnf install qemu-kvm qemu-img git vagrant vagrant-libvirt ansible make libvirt-client python3-netaddr 

For Fedora 38, we have to enable the use_session variable for vagrant libvirt vms to run properly. To do this, create a file ~/.vagrant.d/Vagrantfile with the following content
```
Vagrant.configure("2") do |config|
   config.vm.provider :libvirt do |libvirt|
     libvirt.qemu_use_session = false
   end
end
```

Git clone the sit-environment git repository.
```
$ git clone https://github.com/samba-in-kubernetes/sit-environment.git
```

Build the test environment with the following command
```
$ cd sit-environment/
$ make
```

The first run will take longer than usual as Vagrant downloads the CentOS8 image from its repository. Subsequent runs will use the image from cache and the setup will be quicker.

To run the CentOS9 version of test vms
```
$ cd sit-environment/
$ EXTRA_VARS="use_distro=centos9" make
```

To run the tests using GlusterFS as the backend
```
$ cd sit-environment/
$ EXTRA_VARS="backend=glusterfs" make
```

You can also choose the backend filesystem to use
If you encounter failures bringing up the vagrant vms, you can check for more details by switching into the vagrant directory and manually bring up the machine.
```
$ cd sit-environment/vagrant
$ vagrant up
```
Clean up with a 'make clean' command when done.

The most common fault seen is because of the location of the default storage pool which could lead to permission issues. In this case, edit the default storage pool and switch to a directory which can be accessed by your user.

Before you can reinstall the cluster setup, you will want to clear up the existing machines.
```
$ cd sit-environment/
$ make clean
```
This clears up all the vms and temporary files created by the tool and the system is ready for a rebuild
