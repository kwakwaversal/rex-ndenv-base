# Rex::Ndenv::Base

A Rex module to install [ndenv](https://github.com/riywo/ndenv) (node.js version
manager) which automatically installs [node-build](https://github.com/riywo/node-build)
after setup is complete.

You probably don't want to install ndenv as the root user, so the tasks which
require root permission, and those that do not, have been split into the
`Rex::Ndenv::Base::prepare()` and the `Rex::Ndenv::Base::setup()` functions
respectively.

*N.B., This doesn't prevent you from installing as root, it just makes it easier
when you are not.*

# USAGE

## Rexfile

```perl
include qw/Rex::Ndenv::Base/;

# prepare holds root-specific commands that need running first
task prepare => sub {
  Rex::Ndenv::Base::prepare(@_);  # @_ required for Rex::Ext::ParamLookup
};

auth for => 'prepare' => user => 'root';

task setup => sub {
  Rex::Ndenv::Base::setup(@_);    # @_ required for Rex::Ext::ParamLookup
};
```

Once you have your service's Rexfile created, you need to run your tasks.

```bash
ssh-copy-id root@yourhost.org
rex -H yourhost.org prepare   # will run this as -u root automatically
ssh-copy-id someuser@yourhost.org
rex -H yourhost.org -u someuser setup
```

## meta.yml

In the folder for the Rex service you're creating, add a `meta.yml` file with
something that looks like the following.

```perl
Name: Some frontend service
Description: The frontend service for something
Author: Paul Williams <kwakwa@cpan.org>
Require:
  Rex::Ndenv::Base:
    git: https://github.com/kwakwaversal/rex-ndenv-base.git
    branch: master
```

Once all your dependencies are configured for the service, run `rexify
--resolve-deps` to bundle the module.

## Options

If you want to install a specific version of Node, you can pass the optional
task parameter `--node_version=6.8.0`.

```bash
ssh-copy-id someuser@yourhost.org
rex -H yourhost.org -u someuser setup --node_version=6.8.0
```

# Additional configuration

If you have a firewall, and need to punch a hole in it to be able to install
ndenv, the configuration below might/should help.

## iptables

```bash
-A FORWARD -o eth0 -j NDENV-ENV
-A NDENV-ENV -m state --state ESTABLISHED,RELATED -j ACCEPT
-A NDENV-ENV -d 192.30.252.0/22 -p tcp -m tcp --dport 22    -m comment --comment "ssh://github.com" -j ACCEPT
-A NDENV-ENV -d 192.30.252.0/22 -p tcp -m tcp --dport 443   -m comment --comment "https://github.com" -j ACCEPT
-A NDENV-ENV -d 192.30.252.0/22 -p tcp -m tcp --dport 9418  -m comment --comment "git://github.com" -j ACCEPT
```

# See also
 * [Rex::NTP::Base](https://github.com/krimdomu/rex-ntp-base.git)
 * [Rex::OS::Base](https://github.com/krimdomu/rex-os-base.git)
 * [Example of a complete Rex code infrastructure](http://www.rexify.org/docs/rex_book/infrastructure/example_of_a_complete_rex_code_infrastructure.html)
