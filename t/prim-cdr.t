#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

is_bel_output("(cdr '(a . b))", "b");
is_bel_output("(cdr '(a b))", "(b)");
is_bel_output("(cdr nil)", "nil");
is_bel_output("(cdr)", "nil");
is_bel_error("(cdr 'atom)", "cdr-on-atom");
