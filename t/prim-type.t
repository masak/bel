#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

is_bel_output("(type 'a)", "symbol");
is_bel_output("(type \\a)", "char");
is_bel_output("(type \\bel)", "char");
is_bel_output("(type nil)", "symbol");
is_bel_output("(type '(a))", "pair");
