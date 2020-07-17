#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

is_bel_output("(nom 'a)", q["a"]);
is_bel_error("(nom \\a)", "not-a-symbol");
is_bel_output("(nom nil)", q["nil"]);
is_bel_error("(nom '(a))", "not-a-symbol");
is_bel_error(q[(nom "a")], "not-a-symbol");
