#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(lastcdr nil)", "nil");
    is_bel_output("(lastcdr '(a))", "(a)");
    is_bel_output("(lastcdr '(a b))", "(b)");
    is_bel_output("(lastcdr '(a b c))", "(c)");
    is_bel_output(q[(let p '(c) (id (lastcdr (cons 'a 'b p)) p))], "t");
}
