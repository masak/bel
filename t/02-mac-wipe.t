#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(let x 'hi (wipe x) x)", "nil");
    is_bel_output(
        "(let x '(a b c d e) (wipe 2.x 4.x) x)",
        "(a nil c nil e)");
}
