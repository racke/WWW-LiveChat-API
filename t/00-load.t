#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::LiveChat::API' ) || print "Bail out!\n";
}

diag( "Testing WWW::LiveChat::API $WWW::LiveChat::API::VERSION, Perl $], $^X" );
