package Module::PortablePath;
#########
# Author:        rmp
# Maintainer:    rmp
# Created:       2005-02-14
# Last Modified: 2005-02-14
#
# This modules allows modification of @INC on a package-by-package basis.
# Packages and library paths are defined in /etc/perlconfig.ini
#
# Usage Example:
# use Module::PortablePath qw(core bioperl ensembl cosmic);
#
use strict;
use Exporter;
use Sys::Hostname;
use Config::IniFiles;
use vars qw($CONFIGS $VERSION);
$VERSION = "0.01";
$CONFIGS = {
	    'default' => "/etc/perlconfig.ini",
#	    '^www'    => "/host/specific/path/conf/perlconfig.ini",
	   };

sub config {
  my $cfgfile  = $CONFIGS->{'default'};
  my $hostname = &hostname() || "";

  for my $k (sort { length($a) <=> length($b) } keys %$CONFIGS) {
    if($hostname =~ /$k/) {
      $cfgfile = $CONFIGS->{$k};
      last;
    }
  }

  my $config = Config::IniFiles->new(
				     -file => $cfgfile,
				    );
  return $config;
}

sub import {
  my ($pkg, @args) = @_;
  my $config       = &config();
  my $forward      = {};
  my $reverse      = {};

  for my $param ($config->Parameters("libs")) {
    for my $v (split(/[,\s;:]+/, ($config->val("libs", $param)||""))) {
      $reverse->{$v} = $param;
      unshift @{$forward->{$param}}, $v;
    }
  }

  my $seentags = {};
  for my $i (@INC) {
    next unless($reverse->{$i});
    my ($tag) = $reverse->{$i} =~ /([a-z]+)/;
    $seentags->{$tag} = $reverse->{$i};
  }

  for my $a (@args) {
    unless($forward->{$a}) {
      warn qq(Use of unknown tag "$a");
    }
    for my $i (@{$forward->{$a}}) {
      my ($tag) = $reverse->{$i} =~ /([a-z]+)/;
      if($seentags->{$tag} && ($seentags->{$tag} ne $reverse->{$i})) {
	warn qq(Import of tag "$a" may clash with tag "$seentags->{$tag}");
      }
      unshift @INC, $i;
    }
  }
}

sub dump {
  my $config = &config();
  for my $s (sort $config->Parameters('libs')) {
    printf("%-12s %s\n", $s, $config->val('libs', $s));
  }
}

1;
__END__

=head1 NAME

Module::PortablePath - Perl extension follow modules to exist in different non-core locations on different systems without having to refer to explicit library paths in code

=head1 SYNOPSIS

  use Module::PortablePath qw(tag1 tag2 tag3);

=head1 DESCRIPTION

This module overrides its import() method to fiddle with @INC, adding sets of paths for applications as configured by the system administrator.

It requires Config::IniFiles.

=head1 AUTHOR

Roger Pettett, E<lt>rmp@sanger.ac.ukE<gt>

=head1 COPYRIGHT AND LICENSE
  
Copyright (C) 2005 by Roger Pettett

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
