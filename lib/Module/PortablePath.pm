package Module::PortablePath;
#########
# Author:        rmp
# Maintainer:    rmp
# Created:       2005-02-14
# Last Modified: 2006-10-23
#
# This modules allows modification of @INC nd $ENV{'LD_LIBRARY_PATH'} on a package-by-package basis.
# Packages and library paths are defined in /etc/perlconfig.ini by default
#
# Usage Example:
# use Module::PortablePath qw(core bioperl ensembl cosmic);
#
use strict;
use warnings;
use Exporter;
use Sys::Hostname;
use Config::IniFiles;
our $VERSION = "0.03";
our $CONFIGS = {
		'default' => "/etc/perlconfig.ini",
#		'^www'    => "/host/specific/path/conf/perlconfig.ini",
	       };

=head2 config : Return a Config::IniFiles object appropriate for the execution environment

  my $cfg = Module::PortablePath->config();

=cut
sub config {
  my $cfgfile  = $CONFIGS->{'default'};
  my $hostname = &hostname() || '';

  for my $k (sort { length($a) <=> length($b) } keys %$CONFIGS) {
    if($hostname =~ /$k/) {
      $cfgfile = $CONFIGS->{$k};
      last;
    }
  }

  my $config;
  if(-f $cfgfile) {
    $config = Config::IniFiles->new(
				    -file => $cfgfile,
				   );
  } else {
    $config = Config::IniFiles->new();
  }
  return $config;
}

=head2 import : Perform the path modifications on import (or 'use') of this module

  use Module::PortablePath qw(bioperl ensembl core);

  # or

  require Module::PortablePath;
  Module::PortablePath->import(qw(bioperl ensembl core));

=cut
sub import {
  my ($pkg, @args) = @_;
  return unless(@args);
  my $config       = &config();
  $pkg->_import_libs($config, @args);
  $pkg->_import_ldlibs($config, @args);
}

sub _import_libs {
  my ($pkg, $config, @args) = @_;
  my $forward      = {};
  my $reverse      = {};

  for my $param ($config->Parameters("libs")) {
    for my $v (split(/[,\s;:]+/, ($config->val("libs", $param)||''))) {
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

sub _import_ldlibs {
  my ($pkg, $config, @args) = @_;
  my $forward      = {};
  my $reverse      = {};
  my @LDLIBS       = split(':', $ENV{'LD_LIBRARY_PATH'}||'');

  for my $param ($config->Parameters("ldlibs")) {
    for my $v (split(/[,\s;:]+/, ($config->val("ldlibs", $param)||''))) {
      $reverse->{$v} = $param;
      unshift @{$forward->{$param}}, $v;
    }
  }

  my $seentags = {};
  for my $i (@LDLIBS) {
    next unless($reverse->{$i});
    my ($tag) = $reverse->{$i} =~ /([a-z]+)/;
    $seentags->{$tag} = $reverse->{$i};
  }

  for my $a (@args) {
    next unless($forward->{$a});

    for my $i (@{$forward->{$a}}) {
      my ($tag) = $reverse->{$i} =~ /([a-z]+)/;
      if($seentags->{$tag} && ($seentags->{$tag} ne $reverse->{$i})) {
	warn qq(Import of tag "$a" may clash with tag "$seentags->{$tag}");
      }
      unshift @LDLIBS, $i;
    }
  }

  $ENV{'LD_LIBRARY_PATH'} = join(':', @LDLIBS);
}

=head2 dump : Print out library configuration for this environment

  perl -MModule::PortablePath -e 'Module::PortablePath->dump'

=cut
sub dump {
  my $config = &config();
  for my $l (qw(Libs LDlibs)) {
    print $l, "\n";
    for my $s (sort $config->Parameters(lc($l))) {
      printf("%-12s %s\n", $s, $config->val(lc($l), $s));
    }
    print "\n\n";
  }
}

1;
__END__

=head1 NAME

Module::PortablePath - Perl extension follow modules to exist in different non-core locations on different systems without having to refer to explicit library paths in code

=head1 SYNOPSIS

  use Module::PortablePath qw(tag1 tag2 tag3);

=head1 DESCRIPTION

This module overrides its import() method to fiddle with @INC and $ENV{'LD_LIBRARY_PATH'}, adding sets of paths for applications as configured by the system administrator.

It requires Config::IniFiles.

=head1 AUTHOR

Roger Pettett, E<lt>rmp@sanger.ac.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 GRL

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
