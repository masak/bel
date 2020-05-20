#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(let x '(a b c d e) (drain (pop x)))", "(a b c d e)");
    is_bel_output("(let x '(a b c d e) (drain (pop x)) x)", "nil");
    is_bel_output("(let x '(a b c d e) (drain (pop x) (is 'd)))", "(a b c)");
    is_bel_output("(let x '(a b c d e) (drain (pop x) (is 'd)) x)", "(e)");
}
