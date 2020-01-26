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
    is_bel_output("(apply join '(a b))", "(a . b)");
    is_bel_output("(apply join 'a '(b))", "(a . b)");
    is_bel_output("(apply no '(nil))", "t");
    is_bel_output("(apply no '(t))", "nil");
    is_bel_output("(apply cons '(a b c (d e f)))", "(a b c d e f)");
    is_bel_output("(apply cons '())", "nil");
    is_bel_output("(map apply (list (fn () 'x) (fn () 'y))", "(x y)");
}
