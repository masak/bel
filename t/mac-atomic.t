#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 9;

{
    is_bel_error("lock", "('unboundb lock)");
    is_bel_error("(let f (fn () lock) (f))", "('unboundb lock)");
    is_bel_output("(let f (fn () lock) (atomic (f)))", "t");
    is_bel_output("(atomic 'hi)", "hi");
    is_bel_output("(atomic lock)", "t");
    is_bel_output("(atomic 'no 'but lock)", "t");
    is_bel_output("(atomic (cons (atomic lock) lock))", "(t . t)");
    is_bel_output("(let lock 'lexical (atomic lock))", "t");
    is_bel_output("(atomic (let lock 'lexical lock))", "t");
}
