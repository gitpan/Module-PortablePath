use strict;
use warnings;
use 5.005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      'NAME'          => 'Module::PortablePath',
	      'VERSION_FROM'  => 'lib/Module/PortablePath.pm', # finds $VERSION
	      'PREREQ_PM'     => {
				  'Config::IniFiles' => 2.38,
				 },
	      'ABSTRACT_FROM' => 'lib/Module/PortablePath.pm', # retrieve abstract from module
	      'AUTHOR'        => 'Roger Pettett <rpettett@cpan.org>',
	      'LICENSE'       => 'perl',
	     );
