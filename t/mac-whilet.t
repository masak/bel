#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(with (x '(a b c) y '()) (whilet e (pop x) (push e y)) y)", "(c b a)");
    is_bel_output("(with (x '() y '()) (whilet e (pop x) (push e y)) y)", "nil");
    is_bel_output("(do (mac moo () (letu vx `(whilet ,vx (pop L) (push ,vx K)))) (set K nil))", "nil");
    is_bel_output("(let L '(a b c d) (moo))", "nil");
    is_bel_output("K", "(d c b a)");
}
