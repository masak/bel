#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(caddr nil)", "nil");
    is_bel_output("(caddr '(a))", "nil");
    is_bel_output("(caddr '(a b))", "nil");
    is_bel_output("(caddr '(a b c))", "c");
}
