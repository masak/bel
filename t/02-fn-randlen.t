#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 12;

{
    is_bel_output("(= (randlen 0) 0)", "t");
    is_bel_output("(= (randlen 0) 0)", "t");
    is_bel_output("(= (randlen 0) 0)", "t");
    is_bel_output("(<= 0 (randlen 2) 3)", "t");
    is_bel_output("(<= 0 (randlen 2) 3)", "t");
    is_bel_output("(<= 0 (randlen 2) 3)", "t");
    is_bel_output("(<= 0 (randlen 3) 7)", "t");
    is_bel_output("(<= 0 (randlen 3) 7)", "t");
    is_bel_output("(<= 0 (randlen 3) 7)", "t");
    is_bel_output("(<= 0 (randlen 4) 15)", "t");
    is_bel_output("(<= 0 (randlen 4) 15)", "t");
    is_bel_output("(<= 0 (randlen 4) 15)", "t");
}
