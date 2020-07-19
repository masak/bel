#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

is_bel_output("(stream 'x)", "nil");
is_bel_output("(stream nil)", "nil");
is_bel_output("(stream '(a))", "nil");
is_bel_output("(stream (join))", "nil");
is_bel_output("(stream \\c)", "nil");
is_bel_output(q[(stream (ops "testfile" 'out))], "t");

unlink "testfile";
