#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 5;

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
    is_bel_output("(foldr cons nil '(a b))", "(a b)");
    is_bel_output("(cons 'a (foldr cons nil '(b)))", "(a b)");
    is_bel_output("(cons 'a (cons 'b (foldr cons nil nil)))", "(a b)");
    is_bel_output("(foldr put nil '(a b c) '(x y z))", "((a . x) (b . y) (c . z))");
    is_bel_output("(foldr err nil)", "nil");
}
