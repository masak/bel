#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Language::Bel' ) || print "Bail out!\n";
}

diag( "Testing Language::Bel $Language::Bel::VERSION, Perl $], $^X" );
