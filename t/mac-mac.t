#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(do (mac foo (x) ''b) (foo 'a))", "b");
    is_bel_output("(do (mac bar (x) `(cons ,x ,x)) (bar 'a))", "(a . a)");
}
