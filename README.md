# Vagrant HP Provider

[![Gem Version](https://badge.fury.io/rb/vagrant-hp.png)](http://badge.fury.io/rb/vagrant-hp) [![Dependency Status](https://gemnasium.com/mohitsethi/vagrant-hp.png)](https://gemnasium.com/mohitsethi/vagrant-hp)  [![Code Climate](https://codeclimate.com/github/mohitsethi/vagrant-hp.png)](https://codeclimate.com/github/mohitsethi/vagrant-hp) [![Build Status](https://travis-ci.org/mohitsethi/vagrant-hp.png?branch=master)](https://travis-ci.org/mohitsethi/vagrant-hp) [![Coverage Status](https://coveralls.io/repos/mohitsethi/vagrant-hp/badge.png)](https://coveralls.io/r/mohitsethi/vagrant-hp)


This is a [Vagrant](http://www.vagrantup.com) 1.1+ plugin that adds an [HP](http://www.hpcloud.com)
provider to Vagrant, allowing Vagrant to control and provision machines on HP Cloud.

**NOTE:** This plugin requires Vagrant 1.1+,

## Features

* Boot Servers on HP Cloud
* Auto Floating-IP management
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Minimal synced folder support via `rsync`.

## Usage

Install using standard Vagrant 1.1+ plugin installation methods. After
installing, `vagrant up` and specify the `hp` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-hp
...
$ vagrant up --provider=hp
...
```

Of course prior to doing this, you'll need to obtain an HP-compatible
box file for Vagrant.

## Quick Start

After installing the plugin (instructions above), the quickest way to get
started is to actually use a dummy HP box and specify all the details
manually within a `config.vm.provider` block. So first, add the dummy
box using any name you want:

```
$ vagrant box add dummy https://github.com/mohitsethi/vagrant-hp/raw/master/dummy_hp.box
...
```

And then make a Vagrantfile that looks like the following, filling in
your information where necessary.

```
Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  config.vm.provider :hp do |rs|
    rs.access_key  = "<hp_access_key>"
    rs.secret_key = "<hp_secret_key>"
    rs.flavor   = "standard.xsmall"
    rs.tenant_id = "<hp_tenant_id>"
    rs.server_name = "<server_name>"
    rs.image    = "Ubuntu Precise 12.04 LTS Server 64-bit 20121026 (b)"
    rs.keypair_name = "<your_key_pair_name_on_hpcloud>"
    rs.ssh_private_key_path = "<private_key_location>"
    rs.ssh_username = "<ssh_username>"
    rs.availability_zone = "az1"
    # Security Groups defaults to ["default"]
    # rs.security_groups = ["group1", "group2"]
    rs.floating_ip ="33.33.33.10" # Optional
    rs.network = ["830744ee-38a8-4618-a1eb-7c06fcsdf78", "Test_Network"] # Optional
  end
end
```

And then run `vagrant up --provider=hp`.

This will start an Ubuntu 12.04 instance in the az1 availability zone within
your HP Cloud account. And assuming your SSH information was filled in properly
within your Vagrantfile, SSH and provisioning will work as well.

Note that normally a lot of this boilerplate is encoded within the box
file, but the box file used for the quick start, the "dummy" box, has
no preconfigured defaults.

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `hp` boxes. You can view an example box in
the [example_box/ directory](https://github.com/mohitsethi/vagrant-hp/tree/master/example_box).
That directory also contains instructions on how to build a box.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

This provider exposes quite a few provider-specific configuration options:

* `access_key` - The access key for accessing HP Cloud
* `image` - The Image-id  or Image-Name to boot, such as
    "Ubuntu Precise 12.04 LTS Server 64-bit 20121026 (b)"
* `availability_zone` - The availability zone to launch the server ['us-east', 'us-west'].
    If nil, it will use 'us-west'.
* `flavor` - The type of flavor, such as "standard.xsmall"
* `keypair_name` - The name of the keypair to use to bootstrap image
   which support it.
* `secret_key` - The secret access key for accessing HP Cloud.
* `ssh_private_key_path` - The path to the SSH private key. This overrides
  `config.ssh.private_key_path`.
* `ssh_username` - The SSH username, which overrides `config.ssh.username`.
* `server_name` - The name of the server provisioned on HP Cloud.
* `tenant_id` - The tenant_id to launch the server.
* `security_groups` - An array of strings defining the security groups in which this VM is included.

These can be set like typical provider-specific configuration:


```ruby
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.provider :hp do |rs|
    rs.access_key  = "<hp_access_key>"
    rs.secret_key = "<hp_secret_key>"
    rs.flavor   = "standard.xsmall"
    rs.tenant_id = "<hp_tenant_id>"
    rs.server_name = "<server_name>"
    rs.image    = "Ubuntu Precise 12.04 LTS Server 64-bit 20121026 (b)"
    rs.keypair_name = "<your_key_pair_name_on_hpcloud>"
    rs.ssh_private_key_path = "<private_key_location>"
    rs.ssh_username = "<ssh_username>"
    rs.availability_zone = "az1"
    # Security Groups defaults to ["default"]
    # rs.security_groups = ["group1", "group2"]
    rs.floating_ip ="33.33.33.10" # Optional
    rs.network = ["830744ee-38a8-4618-a1eb-7c06fcsdf78", "Test_Network"] # Optional
  end

end
```

## Networks

Networking features in the form of `config.vm.network` are not
supported with `vagrant-hp`, currently. If any of these are
specified, Vagrant will emit a warning, but will otherwise boot
the HP machine.

## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the HP provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

This is good enough for all built-in Vagrant provisioners (shell,
chef, and puppet) to work!

## Development

To work on the `vagrant-hp` plugin, clone this repository out, and use
[Bundler](http://gembundler.com) to get the dependencies:

```
$ bundle
```

Once you have the dependencies, verify the unit tests pass with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing the plugin. You can test
the plugin without installing it into your Vagrant environment by just
creating a `Vagrantfile` in the top level of this directory (it is gitignored)
that uses it, and uses bundler to execute Vagrant:

```
$ bundle exec vagrant up --provider=hp
```


License and Author

Author:: Mohit Sethi mohit@sethis.in [![endorse](https://api.coderwall.com/mohitsethi/endorsecount.png)](https://coderwall.com/mohitsethi)

Copyright:: 2014, Mohit Sethi
