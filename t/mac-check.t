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
    is_bel_output("(check t idfn)", "t");
    is_bel_output("(check nil idfn)", "nil");
    is_bel_output("(check 2 [= _ 2])", "2");
    is_bel_output("(check 1 [= _ 2])", "nil");
    is_bel_output("(check 2 [= _ 2] 0)", "2");
    is_bel_output("(check 1 [= _ 2] 0)", "0");
    is_bel_output("(do (set x 1) (check (do (set x (inc x)) x) [= _ 2]))", "2");
}
