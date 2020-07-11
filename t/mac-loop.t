#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("(let L nil (loop x 1 (+ x 1) (i< (srnum:numr x) (srnum:numr 5)) (push x L)) L)", "(4 3 2 1)");
    is_bel_output("(let L nil (loop x 1 (+ x 1) (i< (srnum:numr x) (srnum:numr 1)) (push x L)) L)", "nil");
}
