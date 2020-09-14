#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(dups nil)", "nil");
    is_bel_output("(dups '(a b c))", "nil");
    is_bel_output("(dups '(a b b c))", "(b)");
    is_bel_output("(dups '(a nil b c nil))", "(nil)");
    is_bel_output("(dups '(1 2 3 4 3 2))", "(2 3)");
    is_bel_output(q[(dups "abracadabra")], q["abr"]);
    is_bel_output("(dups '(1 2 2 2 3 1 4 2))", "(1 2)");
    is_bel_output("(dups '((a) (b) (a)))", "((a))");
    is_bel_output("(dups '((a) (b) (a)) id)", "nil");
    is_bel_output("(dups '(7 3 0 9 2 4 1) >=)", "(7 3 0)");
}
