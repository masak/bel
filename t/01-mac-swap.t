#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output(
        "(let (x y z) '(a b c) (swap x y z) (list x y z))",
        "(b c a)"
    );
    is_bel_output(
        "(let x '(a b c d e) (swap 2.x 4.x) x)",
        "(a d c b e)"
    );
}
