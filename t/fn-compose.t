#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("((compose no atom) 'x)", "nil");
    is_bel_output("((compose no atom) nil)", "nil");
    is_bel_output("((compose no atom) '(a x))", "t");
    is_bel_output("((compose cdr cdr cdr) '(a b c d))", "(d)");
    is_bel_output("((compose) '(a b c d))", "(a b c d)");
}
