#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(dups nil)", "nil");
    is_bel_output("(dups '(a b c))", "nil");
    is_bel_output("(dups '(a b b c))", "(b)");
    is_bel_output("(dups '(a nil b c nil))", "(nil)");
    is_bel_output("(dups '(1 2 3 4 3 2))", "(2 3)");
    is_bel_output(q[(dups "abracadabra")], q["abr"]);
}
