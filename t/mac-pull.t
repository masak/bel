#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(let l '(a b c b d) (pull 'b l))", "(a c d)");
    is_bel_output("(let l '(a b a c a a d) (pull 'a (cdr l)) l)", "(a b c d)");
    is_bel_output("(do (set l '(d e f)) (pull 'z l))", "(d e f)");
    is_bel_output("(do (set l '(d e f)) (pull 'f (cddr l)) l)", "(d e)");
    is_bel_output("(do (set l '(a)) (pull 'a l))", "nil");
    is_bel_output("(bind l '(g h g i g) (pull 'g l))", "(h i)");
    is_bel_output("(do (def f () (pull 'h l)) (bind l '(g h h h i) (f)))", "(g i)");
    is_bel_output("(let l '((a) (b)) (pull '(b) l))", "((a))");
    is_bel_output("(let l '((a) (b)) (pull '(b) l id))", "((a) (b))");
    is_bel_output("(withs (q '(b) l (list '(a) q)) (pull q l id))", "((a))");
}
