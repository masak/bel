#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

is_bel_output(q[(cls (ops "testfile" 'out))], "<stream>");
is_bel_error(q[(cls (cls (ops "testfile" 'out)))], "'already-closed");
is_bel_error(q[(cls 'not-a-stream)], "'mistype");

unlink "testfile";
