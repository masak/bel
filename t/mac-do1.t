#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(do1 1 2)", "1");
    is_bel_output("(let x 'hi (do1 x (set x 'hey)))", "hi");
    is_bel_output("(let x 'hi (do1 x (set y 'hey)) y)", "hey");
}
