#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

is_bel_output("(~~mem (coin) '(t nil))", "t");
is_bel_output("(whilet _ (coin))", "nil");
is_bel_output("(til _ (coin) no)", "nil");
