#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(list 'a (ccc (fn (c) (set cont c) 'b)))", "(a b)");
    is_bel_output("(cont 'z)", "(a z)");
    is_bel_output("(cont 'w)", "(a w)");
}
