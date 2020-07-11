#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 12;

{
    is_bel_output("(let l '(a b c) (pop l))", "a");
    is_bel_output("(let l '(a b c) (pop l) l)", "(b c)");
    is_bel_output("(let l '(a b c) (pop (cdr l)))", "b");
    is_bel_output("(let l '(a b c) (pop (cdr l)) l)", "(a c)");
    is_bel_output("(do (set l '(d e f)) (pop l))", "d");
    is_bel_output("(do (set l '(d e f)) (pop l) l)", "(e f)");
    is_bel_output("(do (set l '(d e f)) (pop (cddr l)))", "f");
    is_bel_output("(do (set l '(d e f)) (pop (cddr l)) l)", "(d e)");
    is_bel_output("(do (set l '(a)) (pop l) l)", "nil");
    is_bel_output("(bind l '(g h i) (pop l))", "g");
    is_bel_output("(bind l '(g h i) (pop l) l)", "(h i)");
    is_bel_output("(do (def f () (pop l)) (bind l '(g h i) (f) l))", "(h i)");
}
