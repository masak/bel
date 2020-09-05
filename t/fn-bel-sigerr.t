#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 19;

{
    is_bel_error("(bel '(a . b))", "malformed");
    is_bel_error("(bel '(where x))", "unbound");
    is_bel_error("(bel 'x)", "(unboundb x)");
    is_bel_error("(bel '(where 'a))", "unfindable");
    is_bel_error("(bel '(dyn \\x 1 'hi))", "cannot-bind");
    is_bel_error("(bel '((lit . x)))", "bad-lit");
    is_bel_error("(bel '(t))", "cannot-apply");
    is_bel_error("(bel '((lit clo (\\x) nil t)))", "bad-clo");
    is_bel_error("(bel '((lit clo nil \\y t)))", "bad-clo");
    is_bel_error("(bel '((lit cont (\\x) nil)))", "bad-cont");
    is_bel_error("(bel '((lit unp)))", "unapplyable");
    is_bel_error("(bel '(car 'x 'y))", "overargs");
    is_bel_error("(bel '((lit prim unk)))", "unknown-prim");
    is_bel_error("(bel '(no 'a 'b))", "overargs");
    is_bel_error("(pass t nil nil nil nil nil)", "literal-parm");
    is_bel_error("(bel '(no))", "underargs");
    is_bel_error("(bel '((lit clo nil ((x y)) nil) 'd)", "atom-arg");
    is_bel_error("(bel '(join 'a (ccc (lit clo nil (c) (c)))))", "wrong-no-args");
    is_bel_error("(bel '(join 'a (ccc (lit clo nil (c) (c 'x 'y)))))", "wrong-no-args");
}
