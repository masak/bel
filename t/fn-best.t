#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(best < '(5 1 3 2 4))", "1");
    is_bel_output("(best > '(5 1 3 2 4))", "5");
    is_bel_output(
        "(best (of > len) '((a b) (c) (d e) (f)))",
        "(a b)"
    );
    is_bel_output(
        "(best (of < len) '((a b) (c) (d e) (f)))",
        "(c)"
    );
}
