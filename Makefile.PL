use 5.008000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lyrics::Fetcher::LyricWiki',
    VERSION_FROM      => 'lib/Lyrics/Fetcher/LyricWiki.pm', # finds $VERSION
    PREREQ_PM         => { SOAP::Lite => 0 }, 
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lyrics/Fetcher/LyricWiki.pm',
       AUTHOR         => 'David Precious <davidp@preshweb.co.uk>') : ()),
);
