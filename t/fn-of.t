#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(list (car '(a b)) (car '(c d)) (car '(e f)))", "(a c e)");
    is_bel_output("((of list car) '(a b) '(c d) '(e f))", "(a c e)");
    is_bel_output("(let double [list _ _] ((of list double) 'a 'b))", "((a a) (b b))");
    is_bel_output("((of append [list _ _]) 'a 'b 'c)", "(a a b b c c)");
    is_bel_output("((of join (con t)) 'a 'b)", "(t . t)");
}
