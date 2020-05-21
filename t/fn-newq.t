#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(newq)", "(nil)");
    is_bel_output("(id (newq) (newq))", "nil");
}
