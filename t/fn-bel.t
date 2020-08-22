#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

## Testing all possible ways to re-invoke `mev

# literal
{
    is_bel_output("(bel nil)", "nil");
    is_bel_output("(bel t)", "t");
    is_bel_output("(bel \\x)", "\\x");
}

# variable
{
    is_bel_output("(bel 'vmark)", "(nil)");
    # TODO: lexical variable
    # TODO: dynamic variable
    # TODO: unbound variable
    # TODO: inwhere case
}

# TODO: froms (waiting for eif)
# TODO: macro/applym
# TODO: improper lit
# TODO: applyf not a lit
# TODO: locfn
