#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (gets 2 l))", "(b . 2)");
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (gets 4 l))", "nil");
    is_bel_output("(let l nil (gets 5 l))", "nil");
    is_bel_output("(let l '((1 . (a)) (2 . (b)) (3 . (c))) (gets '(b) l))", "(2 b)");
    is_bel_output("(let l '((1 . (a)) (2 . (b)) (3 . (c))) (gets '(b) l id))", "nil");
    is_bel_output("(let q '(b) (let l (list '(1 . (a)) (cons 'two q) '(3 . (c))) (gets q l id))", "(two b)");
}
