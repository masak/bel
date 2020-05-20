#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(let q '((a b c d)) (deq q))", "a");
    is_bel_output("(let q '((b c d)) (deq q))", "b");
    is_bel_output("(let q '((c d)) (deq q))", "c");
    is_bel_output("(let q '((d)) (deq q))", "d");
    is_bel_output("(let q '(()) (deq q))", "nil");
}
