#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(with (x '(a b c) y '()) (whilet e (pop x) (push e y)) y)", "(c b a)");
    is_bel_output("(with (x '() y '()) (whilet e (pop x) (push e y)) y)", "nil");
}
