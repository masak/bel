#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

is_bel_output(q[(withfile f "testfile" 'out (set ff f) (stat f))], "out");
is_bel_output("(stat ff)", "closed");

END {
    unlink("testfile");
}
