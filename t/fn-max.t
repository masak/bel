#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(max 5 1 3 2 4)", "5");
    is_bel_output("(max 3 1 -2 4 0)", "4");
}
