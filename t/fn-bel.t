#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

## Testing all possible ways to re-invoke `mev

# literal
{
    is_bel_output("(bel nil)", "nil");
    is_bel_output("(bel t)", "t");
    is_bel_output("(bel \\x)", "\\x");
}
