#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(array nil)", "nil");
    is_bel_output("(array nil 0)", "0");
    is_bel_output("(array nil 'x)", "x");
    is_bel_output("(array '(3) 0)", "(lit arr 0 0 0)");
    is_bel_output("(array '(0) 'x)", "(lit arr)");
    my $l0 = "0";
    my $l1 = "(lit arr $l0 $l0)";
    my $l2 = "(lit arr $l1 $l1)";
    is_bel_output("(array '(2 2) 0)", $l2);
    my $l3 = "(lit arr $l2 $l2)";
    is_bel_output("(array '(2 2 2) 0)", $l3);
}