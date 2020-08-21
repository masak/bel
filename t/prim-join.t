#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

is_bel_output("(join 'a 'b)", "(a . b)");
is_bel_output("(join 'a)", "(a)");
is_bel_output("(join)", "(nil)");
is_bel_output("(join nil 'b)", "(nil . b)");
is_bel_output("(id (join 'a 'b) (join 'a 'b))", "nil");
