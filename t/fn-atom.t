#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(atom \\a)", "t");
    is_bel_output("(atom nil)", "t");
    is_bel_output("(atom 'a)", "t");
    is_bel_output("(atom '(a))", "nil");
}
