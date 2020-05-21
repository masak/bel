#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(tail idfn nil)", "nil");
    is_bel_output("(tail car '(a b c))", "(a b c)");
    is_bel_output("(tail car '(nil b c))", "(b c)");
    is_bel_output("(tail no:cdr '(a b c))", "(c)");
    is_bel_output(q!(tail [caris _ \-] "non-nil")!, q["-nil"]);
}
