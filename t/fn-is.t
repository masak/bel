#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 6;

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
    is_bel_output("((is car) car)", "t");
    is_bel_output("((is car) cdr)", "nil");
    is_bel_output("((is 'x) 'x)", "t");
    is_bel_output("((is 'x) 'y)", "nil");
    is_bel_output("((is 'x) \\x)", "nil");
    is_bel_output("((is (join)) (join))", "t");
}
