#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 2;

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
    is_bel_output(
        "(do (set k (table '((z . 2) (a . 1) (c . d)))) (tabrem k 'z))",
        "((a . 1) (c . d))"
    );
    is_bel_output(
        "(do (set k (table '((z . 2) (a . 1) (c . d)))) (tabrem k 'z) k)",
        "(lit tab (a . 1) (c . d))"
    );
}
