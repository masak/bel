#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(sort < '(5 1 3 2 4))", "(1 2 3 4 5)");
    is_bel_output(
        "(sort (of > len) '((a b) (c) (d e) (f)))",
        "((a b) (d e) (c) (f))"
    );
}
