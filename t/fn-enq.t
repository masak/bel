#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(let q (newq) (enq 'a q))", "((a))");
    is_bel_output("(let q (newq) (enq 'a q) (enq 'b q))", "((a b))");
    is_bel_output("(let q (newq) (enq 'a q) (enq 'b q) (enq 'c q))", "((a b c))");
}
