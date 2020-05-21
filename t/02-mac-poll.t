#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(let x '(a b c d e) (poll (pop x) (is 'c)) x)", "(d e)");
    is_bel_output("(let x '(c) (poll (pop x) (is 'c)) x)", "nil");
}
