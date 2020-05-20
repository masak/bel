#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output(q[(dedup "abracadabra")], q["abrcd"]);
    is_bel_output("(dedup '(1 2 2 2 3 1 4 2))", "(1 2 3 4)");
    is_bel_output("(dedup '((a) (b) (a)))", "((a) (b))");
    is_bel_output("(dedup '((a) (b) (a)) id)", "((a) (b) (a))");
}
