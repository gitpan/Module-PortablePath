use 5.005;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Module::PortablePath',
    VERSION_FROM      => 'lib/Module/PortablePath.pm', # finds $VERSION
    PREREQ_PM         => {Config::IniFiles => 2.38}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Module/PortablePath.pm', # retrieve abstract from module
       AUTHOR         => 'Roger M Pettett <rmp@sanger.ac.uk>') : ()),
);
