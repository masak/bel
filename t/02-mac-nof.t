#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(nof 5 'hi)", "(hi hi hi hi hi)");
    is_bel_output("(nof 3 '(s))", "((s) (s) (s))");
    is_bel_output("(nof 0 '(s))", "nil");
    is_bel_output("(let L (nof 3 '(s)) (= (car L) (cadr L)))", "t");
    is_bel_output("(let L (nof 3 '(s)) (id (car L) (cadr L)))", "t");
    is_bel_output("(let n 0 (nof 4 (++ n)))", "(1 2 3 4)");
}
