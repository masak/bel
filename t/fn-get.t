#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (get 'b l))", "(b . 2)");
    is_bel_output("(let l '((a . 1) (b . 2) (c . 3)) (get 'd l))", "nil");
    is_bel_output("(let l nil (get 'x l))", "nil");
    is_bel_output("(let l '(((a) . 1) ((b) . 2) ((c) . 3)) (get '(b) l))", "((b) . 2)");
    is_bel_output("(let l '(((a) . 1) ((b) . 2) ((c) . 3)) (get '(b) l id))", "nil");
    is_bel_output("(let q '(b) (let l (list '((a) . 1) (cons q 'two) '((c) . 3)) (get q l id))", "((b) . two)");
}
