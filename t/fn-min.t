#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(min 5 1 3 2 4)", "1");
    is_bel_output("(min 3 1 -2 4 0)", "-2");
}
