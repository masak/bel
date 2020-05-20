#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(let l '(b c) (push 'a l) l)", "(a b c)");
    is_bel_output("(let l '(b c) (push 'a (cdr l)) l)", "(b a c)");
    is_bel_output("(do (set l '(e f)) (push 'd l) l)", "(d e f)");
    is_bel_output("(do (set l '(e f)) (push 'd (cddr l)) l)", "(e f d)");
    is_bel_output("(do (set l nil) (push 'a l) l)", "(a)");
    is_bel_output("(bind l '(h i) (push 'g l) l)", "(g h i)");
    is_bel_output("(do (def f (v) (push 'g l)) (bind l '(h i) (f 'g) l))", "(g h i)");
}
