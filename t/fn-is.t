#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("((is car) car)", "t");
    is_bel_output("((is car) cdr)", "nil");
    is_bel_output("((is 'x) 'x)", "t");
    is_bel_output("((is 'x) 'y)", "nil");
    is_bel_output("((is 'x) \\x)", "nil");
    is_bel_output("((is (join)) (join))", "t");
}
