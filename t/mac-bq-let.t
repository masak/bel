#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(bq-let x 'a (cons x 'b))", "(a . b)");
    is_bel_output("(bq-let x 'a (cons (let x 'b x) x))", "(b . a)");
    is_bel_output("(bq-let x 'a (let y 'b (list x y)))", "(a b)");
}
