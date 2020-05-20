#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(idfn nil)", "nil");
    is_bel_output("(idfn '(a b c))", "(a b c)");
    is_bel_output("(idfn \\bel)", "\\bel");
    is_bel_output("(idfn 'x)", "x");
}
