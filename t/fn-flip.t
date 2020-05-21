#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("((flip -) 1 10)", "9");
    is_bel_output("((flip list) 5 4 3 2 1)", "(1 2 3 4 5)");
    is_bel_output("((flip all) '(nil nil nil) no)", "t");
}
