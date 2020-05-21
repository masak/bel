#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("((cor pair no) nil)", "t");
    is_bel_output("((cor pair no) t)", "nil");
    is_bel_output("((cor pair no) '(x y))", "t");
    is_bel_output("((cor pair) (join))", "t");
    is_bel_output("((cor) nil)", "nil");
}
