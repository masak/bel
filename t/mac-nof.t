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
    is_bel_output("(nof 5 'hi)", "(hi hi hi hi hi)");
    is_bel_output("(nof 3 '(s))", "((s) (s) (s))");
    is_bel_output("(nof 0 '(s))", "nil");
    is_bel_output("(let L (nof 3 '(s)) (= (car L) (cadr L)))", "t");
    is_bel_output("(let L (nof 3 '(s)) (id (car L) (cadr L)))", "t");
    is_bel_output("(let n 0 (nof 4 (++ n)))", "(1 2 3 4)");
}
