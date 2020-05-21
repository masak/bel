#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(with (L nil x '(a b c d e)) (til y (pop x) (= y 'c) (push y L)) L)", "(b a)");
    is_bel_output("(with (L nil x '(a b c d e)) (til y (pop x) (= y 'c) (push y L)) x)", "(d e)");
    is_bel_output("(with (L nil x '(c)) (til y (pop x) (= y 'c) (push y L)) L)", "nil");
    is_bel_output("(with (L nil x '(c)) (til y (pop x) (= y 'c) (push y L)) x)", "nil");
}
