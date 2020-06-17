#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(bq-pcase nil no 'one char 'two 'three)", "one");
    is_bel_output("(bq-pcase \\x no 'one char 'two 'three)", "two");
    is_bel_output("(bq-pcase (join) no 'one char 'two 'three)", "three");
    is_bel_output(q[(bq-pcase "hi" string 'four function 'five)], "four");
    is_bel_output("(bq-pcase idfn string 'four function 'five)", "five");
    is_bel_output("(bq-pcase car string 'four function 'five)", "five");
    is_bel_output("(bq-pcase 'symbol string 'four function 'five)", "nil");
}
