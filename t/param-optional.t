#!perl -w
# -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 20;

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
    is_bel_output("((lit clo nil ((o x)) x) 'a)", "a");
    is_bel_output("((lit clo nil ((o x)) x))", "nil");
    is_bel_output("((lit clo nil ((o x 'b)) x) 'a)", "a");
    is_bel_output("((lit clo nil ((o x 'b)) x))", "b");
    is_bel_output("((lit clo nil ((o x) (o y)) (list x y)) 'a 'b)", "(a b)");
    is_bel_output("((lit clo nil ((o x) (o y)) (list x y)) 'a)", "(a nil)");
    is_bel_output("((lit clo nil ((o x) (o y)) (list x y)))", "(nil nil)");
    is_bel_output("((lit clo nil ((o x) (o y x)) (list x y)) 'c)", "(c c)");
    is_bel_output("((fn ((o x)) x) 'a)", "a");
    is_bel_output("((fn ((o x)) x))", "nil");
    is_bel_output("((fn ((o x 'b)) x) 'a)", "a");
    is_bel_output("((fn ((o x 'b)) x))", "b");
    is_bel_output("((fn ((o x) (o y)) (list x y)) 'a 'b)", "(a b)");
    is_bel_output("((fn ((o x) (o y)) (list x y)) 'a)", "(a nil)");
    is_bel_output("((fn ((o x) (o y)) (list x y)))", "(nil nil)");
    is_bel_output("((fn ((o x) (o y x)) (list x y)) 'c)", "(c c)");
    is_bel_output("(let ((o x)) '(a) x)", "a");
    is_bel_output("(let ((o x)) '() x)", "nil");
    is_bel_output("(let ((o x 'b)) '(a) x)", "a");
    is_bel_output("(let ((o x 'b)) '() x)", "b");
}
