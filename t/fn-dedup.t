#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output(q[(dedup "abracadabra")], q["abrcd"]);
    is_bel_output("(dedup '(1 2 2 2 3 1 4 2))", "(1 2 3 4)");
    is_bel_output("(dedup '((a) (b) (a)))", "((a) (b))");
    is_bel_output("(dedup '((a) (b) (a)) id)", "((a) (b) (a))");
    is_bel_output("(dedup '(7 3 0 9 2 4 1) >=)", "(7 9)");
}
