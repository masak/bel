#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(let L nil (repeat 5 (push 'hi L)) L)", "(hi hi hi hi hi)");
    is_bel_output("(let L nil (repeat 1 (push 'hi L)) L)", "(hi)");
    is_bel_output("(let L nil (repeat 0 (push 'hi L)) L)", "nil");
    is_bel_output("(let L nil (repeat -2 (push 'hi L)) L)", "nil");
}
