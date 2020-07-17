#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

is_bel_output("(car '(a . b))", "a");
is_bel_output("(car '(a b))", "a");
is_bel_output("(car nil)", "nil");
is_bel_output("(car)", "nil");
is_bel_error("(car 'atom)", "car-on-atom");
