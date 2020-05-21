#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(cddr nil)", "nil");
    is_bel_output("(cddr '(a))", "nil");
    is_bel_output("(cddr '(a b))", "nil");
    is_bel_output("(cddr '(a b c))", "(c)");
}
