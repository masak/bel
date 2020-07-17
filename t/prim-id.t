#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 11;

is_bel_output("(id 'a 'a)", "t");
is_bel_output("(id 'a 'b)", "nil");
is_bel_output("(id 'a \\a)", "nil");
is_bel_output("(id \\a \\a)", "t");
is_bel_output("(id 't t)", "t");
is_bel_output("(id nil 'nil)", "t");
is_bel_output("(id id id)", "t");
is_bel_output("(id id 'id)", "nil");
is_bel_output("(id id nil)", "nil");
is_bel_output("(id nil)", "t");
is_bel_output("(id)", "t");
