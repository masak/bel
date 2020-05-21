#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output(
        "(let x '(1 2 3 4 5) (clean odd x))",
        "(2 4)"
    );
    is_bel_output(
        "(let x '(1 2 3 4 5) (clean odd x) x)",
        "(2 4)"
    );
}
