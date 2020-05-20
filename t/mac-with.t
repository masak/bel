#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(with (x 'a y 'b) (cons x y))", "(a . b)");
    is_bel_output("(let x 'a (with (x 'b y x) y))", "a");
}
