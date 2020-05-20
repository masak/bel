#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(record (enq \\a outs) (enq \\b outs) (enq \\c outs))", q["abc"]);
    is_bel_output("(record (map [enq _ outs] '(\\x \\y \\z)))", q["xyz"]);
    is_bel_output("(record)", "nil");
    bel_todo("~~pr", "t", "('unboundb pr)");
}
