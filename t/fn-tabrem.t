#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output(
        "(do (set k (table '((z . 2) (a . 1) (c . d)))) (tabrem k 'z))",
        "((a . 1) (c . d))"
    );
    is_bel_output(
        "(do (set k (table '((z . 2) (a . 1) (c . d)))) (tabrem k 'z) k)",
        "(lit tab (a . 1) (c . d))"
    );
}
