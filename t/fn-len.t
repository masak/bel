#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(len nil)", "0");
    is_bel_output("(len '(t))", "1");
    is_bel_output("(len '(t t))", "2");
    is_bel_output("(len '(t t t))", "3");
    is_bel_output("(len '(t t t t))", "4");
}
