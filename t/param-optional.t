#!perl -w
# -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 20;

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
