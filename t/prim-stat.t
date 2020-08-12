#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

is_bel_output(q[(stat (ops "testfile" 'out))], "out");
is_bel_output(q[(stat (cls (ops "testfile" 'out)))], "closed");

END {
    unlink("testfile");
}
