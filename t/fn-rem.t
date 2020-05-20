#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output(q[(rem \\a "abracadabra")], q["brcdbr"]);
    is_bel_output("(rem 'b '(a b c b a b))", "(a c a)");
    is_bel_output("(rem 'b '(a c a))", "(a c a)");
    is_bel_output("(rem 'x nil)", "nil");
    is_bel_output("(rem '() '(a () c () a ()))", "(a c a)");
    is_bel_output("(rem '(z) '(a (z) c) id)", "(a (z) c)");
}
