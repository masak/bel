#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 7;

my $actual_output = "";
my $b = Language::Bel->new({ output => sub {
    my ($string) = @_;
    $actual_output = "$actual_output$string";
} });

sub is_bel_output {
    my ($expr, $expected_output) = @_;

    $actual_output = "";
    $b->eval($expr);

    is($actual_output, $expected_output, "$expr ==> $expected_output");
}

{
    is_bel_output("(pcase nil no 'one char 'two 'three)", "one");
    is_bel_output("(pcase \\x no 'one char 'two 'three)", "two");
    is_bel_output("(pcase (join) no 'one char 'two 'three)", "three");
    is_bel_output(q[(pcase "hi" string 'four function 'five)], "four");
    is_bel_output("(pcase idfn string 'four function 'five)", "five");
    is_bel_output("(pcase car string 'four function 'five)", "five");
    is_bel_output("(pcase 'symbol string 'four function 'five)", "nil");
}
