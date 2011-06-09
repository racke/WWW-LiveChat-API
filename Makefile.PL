use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::LiveChat::API',
    AUTHOR              => q{Stefan Hornburg (Racke) <racke@linuxia.de>},
    VERSION_FROM        => 'lib/WWW/LiveChat/API.pm',
    ABSTRACT_FROM       => 'lib/WWW/LiveChat/API.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Crypt::SSLeay' => 0,
        'LWP::UserAgent' => 0,
        'URI::Escape' => 0,
        'JSON' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-LiveChat-API-*' },
);
