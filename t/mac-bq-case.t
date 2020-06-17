#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(let x 'a (bq-case x a 'm))", "m");
    is_bel_output("(let x 'b (bq-case x a 'm))", "nil");
    is_bel_output("(let x 'a (bq-case x a 'm 'n))", "m");
    is_bel_output("(let x 'b (bq-case x a 'm 'n))", "n");
    is_bel_output("(let x 'a (bq-case x a 'm b 'n))", "m");
    is_bel_output("(let x 'b (bq-case x a 'm b 'n))", "n");
    is_bel_output("(let x 'c (bq-case x a 'm b 'n))", "nil");
    is_bel_output("(let x 'a (bq-case x a 'm b 'n 'o))", "m");
    is_bel_output("(let x 'b (bq-case x a 'm b 'n 'o))", "n");
    is_bel_output("(let x 'c (bq-case x a 'm b 'n 'o))", "o");
}
