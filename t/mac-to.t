#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 1;

is_bel_output(q[(to "alsieu" 'choo)], "choo");

END {
    unlink("alsieu");
}
