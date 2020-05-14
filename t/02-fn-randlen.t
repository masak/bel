#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 12;

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
    is_bel_output("(= (randlen 0) 0)", "t");
    is_bel_output("(= (randlen 0) 0)", "t");
    is_bel_output("(= (randlen 0) 0)", "t");
    is_bel_output("(<= 0 (randlen 2) 3)", "t");
    is_bel_output("(<= 0 (randlen 2) 3)", "t");
    is_bel_output("(<= 0 (randlen 2) 3)", "t");
    is_bel_output("(<= 0 (randlen 3) 7)", "t");
    is_bel_output("(<= 0 (randlen 3) 7)", "t");
    is_bel_output("(<= 0 (randlen 3) 7)", "t");
    is_bel_output("(<= 0 (randlen 4) 15)", "t");
    is_bel_output("(<= 0 (randlen 4) 15)", "t");
    is_bel_output("(<= 0 (randlen 4) 15)", "t");
}
