#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

is_bel_output("(len cbuf)", "1");
is_bel_output(q[(set s (open "testfile" 'out))], "<stream>");
is_bel_output("(len cbuf)", "2");
is_bel_output("(close s)", "<stream>");
is_bel_output("(len cbuf)", "1");

END {
    unlink("testfile");
}
