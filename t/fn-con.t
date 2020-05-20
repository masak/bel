#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("((con 'a) 'b)", "a");
    is_bel_output("((con nil) 'c)", "nil");
    is_bel_output("((con '(x y)) nil)", "(x y)");
    is_bel_output("(map (con t) '(a b c))", "(t t t)");
}
