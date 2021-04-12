#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test qw(
    slurp_file
);

use Language::Bel::Globals::FastFuncs::Preprocessor qw(
    preprocess
);

plan tests => 1;

{
    my $actual_fastfuncs = slurp_file("lib/Language/Bel/Globals/FastFuncs.pm");
    my $generated_fastfuncs = preprocess();

    is $actual_fastfuncs, $generated_fastfuncs, "the fastfuncs are up to date";
}
