#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(insert < 3 nil)", "(3)");
    is_bel_output("(insert < 3 '(1 2 4 5))", "(1 2 3 4 5)");
}
