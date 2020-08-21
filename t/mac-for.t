#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(let L nil (for n 1 5 (push n L)) L)", "(5 4 3 2 1)");
    is_bel_output("(let L nil (for n 3 3 (push n L)) L)", "(3)");
    is_bel_output("(let L nil (for n 4 1 (push n L)) L)", "nil");
}
