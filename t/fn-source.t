#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

is_bel_output("(source nil)", "t");
is_bel_output("(source 'x)", "nil");
is_bel_output(q[(source (open "testfile" 'out))], "t");
is_bel_output("(source '(x))", "nil");
is_bel_output(q[(source (list ""))], "t");
is_bel_output(q[(source (list "abc"))], "t");
is_bel_output(q[(source (list \\c))], "nil");

END {
    unlink("testfile");
}
