#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(c* (list (list '+ i1 i1) (list '+ i0 i1)) " .
        "(list (list '+ i1 i1) (list '+ i0 i1)))",
        "((+ (t) (t)) (+ nil (t)))");
    is_bel_output("(c* (list (list '+ i1 i1) (list '+ i0 i1)) " .
        "(list (list '- i1 i1) (list '+ i0 i1)))",
        "((- (t) (t)) (- nil (t)))");
    is_bel_output("(c* (list (list '+ i0 i1) (list '+ i1 i1)) " .
        "(list (list '+ i0 i1) (list '+ i1 i1)))",
        "((- (t) (t)) (+ nil (t)))");
    is_bel_output("(c* (list (list '+ i0 i1) (list '- i1 i1)) " .
        "(list (list '+ i0 i1) (list '- i1 i1)))",
        "((- (t) (t)) (- nil (t)))");
    is_bel_output("(c* (list (list '+ i2 '(t t t)) (list '+ i1 i1)) " .
        "(list (list '+ i1 '(t t t)) (list '- i1 i1)))",
        "((+ (t t t t t t t t t t t) (t t t t t t t t t)) " .
        "(- (t t t) (t t t t t t t t t)))");
}
