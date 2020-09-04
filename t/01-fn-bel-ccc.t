#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 1;

#  This test is so slow it ends up in its own .t file

# 'ccc' form
{
    is_bel_output("(bel '(list 'a (ccc (lit clo nil (c) 'b))))", "(a b)");
}
