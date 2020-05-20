#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(fuse idfn '((a b) (c d) (e f)))", "(a b c d e f)");
    is_bel_output("(fuse list '(a b c) '(1 2 3))", "(a 1 b 2 c 3)");
    is_bel_output("(fuse list '(a b c) '(1 2))", "(a 1 b 2)");
    is_bel_output("(fuse join)", "nil");
    is_bel_error("(fuse car '(a b c) '(1 2 3))", "car-on-atom");
}
