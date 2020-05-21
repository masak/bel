#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("((trap cons 'a) 'b)", "(b . a)");
    is_bel_output("((trap list 1 2 3) 4 5)", "(4 5 1 2 3)");
    is_bel_output("((trap no) t)", "nil");
    is_bel_output("((trap no) nil)", "t");
}
