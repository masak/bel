#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_error(q[(list "hello be" . \\l)], "'malformed");
    is_bel_error("(cons \\e . \\l)", "'malformed");
    is_bel_error("(\\e . \\l)", "'malformed");
    is_bel_output("((lit clo nil nil))", "nil");
}
