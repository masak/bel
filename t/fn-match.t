#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(match '(a b c) '(a b c))", "t");
    is_bel_output("(match '(a b c) '(a D c))", "nil");
    is_bel_output("(match '(a b c) '(a t c))", "t");
    is_bel_output("(match '(a b c) '(t t t))", "t");
    is_bel_output("(match '(a b c) '(t t))", "nil");
    is_bel_output("(match '(a b c) '(t t t t))", "nil");
    is_bel_output("(match '(a b c) (list 'a symbol 'c))", "t");
    is_bel_output("(match '(a b c) (list symbol symbol symbol))", "t");
    is_bel_output("(match '(a b c) (list symbol pair symbol))", "nil");
    is_bel_output("(match '(a (b) c) (list symbol pair symbol))", "t");
}
