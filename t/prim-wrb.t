#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 1;

is_bel_output("(do (each c (list \\0 \\0 \\1 \\0 \\0 \\0 \\0 \\1) (wrb c nil)) nil)", "!nil");
