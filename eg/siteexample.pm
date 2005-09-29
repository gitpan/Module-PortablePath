#########
# An example of how to derive from Module::PortablePath
# and supply site-specific paths which aren't /etc/perlconfig.ini
#
# You'd probably want to rename this file and package
# from siteexample to something like MySitePaths
#
# then your scripts could:
# use MySitePaths qw(myapp1 mylibs2);
#
package siteexample;
use strict;
use Module::PortablePath;
our $VERSION = "1.9";

sub import {
  $Module::PortablePath::CONFIGS = {
				    'default'      => "/path/to/mysite/default/perlconfig.ini",
				    '^webcluster'  => "/lustre/data/www/conf/perlconfig.ini",
				    '^workcluster' => "/work/conf/perlconfig/ini",
				   };

  &Module::PortablePath::import(@_);
}

1;
