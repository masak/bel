#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 26;

{
    is_bel_output("(okparms nil)", "t");
    is_bel_output("(okparms 'args)", "t");
    is_bel_output("(okparms 't)", "nil");
    is_bel_output("(okparms 'o)", "nil");
    is_bel_output("(okparms 'apply)", "nil");
    is_bel_output("(okparms (uvar))", "t");
    is_bel_output("(okparms '(t x int))", "t");
    is_bel_output("(okparms '(t x int y))", "nil");
    is_bel_output("(okparms '(t x int))", "t");
    is_bel_output("(okparms '(t x int y))", "nil");
    is_bel_output("(okparms '(o y 0))", "nil");
    is_bel_output("(okparms '(o y))", "nil");
    is_bel_output("(okparms '(o y (+ 2 2)))", "nil");
    is_bel_output("(okparms '((o y 0)))", "t");
    is_bel_output("(okparms '((o y 0 x)))", "nil");
    is_bel_output("(okparms '((o y)))", "t");
    is_bel_output("(okparms '((o y (+ 2 2))))", "t");
    is_bel_output("(okparms '(a b))", "t");
    is_bel_output("(okparms '(a (o b)))", "t");
    is_bel_output("(okparms '(a (o b) c))", "t");
    is_bel_output("(okparms '(a (o b 0) c))", "t");
    is_bel_output("(okparms '(a (o b 0 1) c))", "nil");
    is_bel_output("(okparms '(a . rest))", "t");
    is_bel_output("(okparms '(a b . rest))", "t");
    is_bel_output("(okparms '(a (b c) d))", "t");
    is_bel_output("(okparms '(a (b . rest) d))", "t");
}
