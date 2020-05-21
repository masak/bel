#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(with (x '(a b c) L '()) (while (pop x) (push x L)) L)", "(nil (c) (b c))");
    is_bel_output("(with (x '() L '()) (while (pop x) (push x L)) L)", "nil");
}
