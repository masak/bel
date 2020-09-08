#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("(after 1 2)", "1");
    is_bel_error(q[(after 3 (car 'atom))], "car-on-atom");
    is_bel_output("(do (after (set x 1) (set x 2)) x)", "2");
}
