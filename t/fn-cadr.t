#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(cadr nil)", "nil");
    is_bel_output("(cadr '(a))", "nil");
    is_bel_output("(cadr '(a b))", "b");
    is_bel_output("(cadr '(a b c))", "b");
}
