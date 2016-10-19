#
# AUTHOR: Paul Williams <kwakwa@cpan.org>
# REQUIRES: build-essential, git
# LICENSE: Apache License 2.0
#
# A Rex module to install ndenv and build node on your Server.

package Rex::Ndenv::Base;

use Rex -base;
use Rex::Ext::ParamLookup;

our %version_map = (
  debian => "6.8.0",
  ubuntu => "6.8.0",
  centos => "6.8.0",
  redhat => "6.8.0",
);

# The prepare task needs root privileges. Run as root.
task prepare => make {
  pkg [qw/build-essential git/], ensure => "latest";
};

task setup => make {
  my $node_version = param_lookup "node_version",
    $version_map{ lc get_operating_system };

  # Commands taken from
  #
  # https://github.com/riywo/ndenv

  # Check out ndenv into ~/.ndenv
  run 'ls ~/.ndenv';
  if ($? == 0) {
    Rex::Logger::info "ndenv has already been installed";
  }
  else {
    run 'git clone git://github.com/riywo/ndenv.git ~/.ndenv';
  }

  # Add ~/.ndenv/bin to your $PATH for access to the ndenv command-line utility.
  # Add ndenv init to your shell to enable shims and autocompletion.
  run 'touch ~/.bash_profile';
  append_if_no_such_line '~/.bash_profile', 'export PATH="$HOME/.ndenv/bin:$PATH"';
  append_if_no_such_line '~/.bash_profile', 'eval "$(ndenv init -)"';

  # Install node-build, which provides a ndenv install command that simplifies
  # the process of installing new Node versions.
  run 'ls ~/.ndenv/plugins/node-build/';
  if ($? == 0) {
    Rex::Logger::info "node-build has already been installed";
  }
  else {
    run 'git clone git://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build/';
  }

  # Additional commands to make ndenv more perlbrew-like
  # run 'git clone git://github.com/miyagawa/ndenv-contrib.git ~/.ndenv/plugins/ndenv-contrib/';

  # Add ~/ndenv/bin to the Rex $PATH so it will be used for ndenv commands
  my @new_path;
  push(@new_path, '$HOME/.ndenv/bin');
  push(@new_path, Rex::Config->get_path);
  Rex::Config->set_path(\@new_path);

  # Install node!
  run "ndenv versions |grep $node_version";    # this is probably a bug
  if ($? == 0) {
    Rex::Logger::info "perl-$node_version has already been installed";
  }
  else {
    run "ndenv install $node_version";
  }
};

1;
