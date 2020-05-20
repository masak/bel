#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(let L '() (each n '(1 2 3) (push (inc n) L)) L)", "(4 3 2)");
    is_bel_output("(let L '() (each n '() (push (inc n) L)) L)", "nil");
    is_bel_output("(let L '((a) (b) (c)) (each e L (xar e 'z)) L)", "((z) (z) (z))");
    is_bel_output("(let x nil (each y '(a b c) (push y x)) x)", "(c b a)");
}
