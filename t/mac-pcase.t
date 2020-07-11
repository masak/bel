#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(pcase nil no 'one char 'two 'three)", "one");
    is_bel_output("(pcase \\x no 'one char 'two 'three)", "two");
    is_bel_output("(pcase (join) no 'one char 'two 'three)", "three");
    is_bel_output(q[(pcase "hi" string 'four function 'five)], "four");
    is_bel_output("(pcase idfn string 'four function 'five)", "five");
    is_bel_output("(pcase car string 'four function 'five)", "five");
    is_bel_output("(pcase 'symbol string 'four function 'five)", "nil");
}
