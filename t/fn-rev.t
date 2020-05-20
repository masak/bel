#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(rev nil)", "nil");
    is_bel_output("(rev '(a b c))", "(c b a)");
    is_bel_output("(rev '(a (x y) c))", "(c (x y) a)");
}
