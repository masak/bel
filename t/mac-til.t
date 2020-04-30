#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 4;

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
    is_bel_output("(with (L nil x '(a b c d e)) (til y (pop x) (= y 'c) (push y L)) L)", "(b a)");
    is_bel_output("(with (L nil x '(a b c d e)) (til y (pop x) (= y 'c) (push y L)) x)", "(d e)");
    is_bel_output("(with (L nil x '(c)) (til y (pop x) (= y 'c) (push y L)) L)", "nil");
    is_bel_output("(with (L nil x '(c)) (til y (pop x) (= y 'c) (push y L)) x)", "nil");
}
