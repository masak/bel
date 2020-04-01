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
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (gets 2 l))", "(b . 2)");
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (gets 4 l))", "nil");
    is_bel_output("(let l nil (gets 5 l))", "nil");
    is_bel_output("(let l '((1 . (a)) (2 . (b)) (3 . (c))) (gets '(b) l))", "(2 b)");
    is_bel_output("(let l '((1 . (a)) (2 . (b)) (3 . (c))) (gets '(b) l id))", "nil");
    is_bel_output("(let q '(b) (let l (list '(1 . (a)) (cons 'two q) '(3 . (c))) (gets q l id))", "(two b)");
}
