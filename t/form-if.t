#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(if)", "nil");
    is_bel_output("(if 'a)", "a");
    is_bel_output("(if 'a 'b)", "b");
    is_bel_output("(if 'a 'b 'c)", "b");
    is_bel_output("(if nil 'b 'c)", "c");
}
