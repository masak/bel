#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(do 'a 'b 'c (list 'hello 'world))", "(hello world)");
    is_bel_output("(do)", "nil");
    is_bel_output("(do 'x 'y)", "y");
}
