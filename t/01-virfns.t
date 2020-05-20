#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 11;

{
    is_bel_output("(2 '(a b c))", "b");
    is_bel_output("(let a (array '(3) 0) (a 2))", "0");
    is_bel_output("(let a (array '(3) 'x) (a 3))", "x");
    is_bel_output("(let a (array '(2 2) 0) (a 2 1))", "0");
    is_bel_output("(let a (array '(2 2) 'x) (a 1 2))", "x");
    is_bel_output("(let tab (table '((a . 1) (b . 2))) (tab 'a))", "1");
    is_bel_output("(let tab (table '((a . 1) (b . 2))) (tab 'b))", "2");
    is_bel_output("(let tab (table '((a . 1) (b . 2))) (tab 'c))", "nil");
    is_bel_output("(let tab (table '((a . 1) (b . 2))) (tab 'c 3))", "3");
    is_bel_output("(let tab (table '((x . 1) (x . 2))) (tab 'x))", "1");
    is_bel_output("(do (push (cons 'num (fn (f args) ''haha)) virfns) (2 '(a b c)))", "haha");
}
