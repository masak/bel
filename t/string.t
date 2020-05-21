#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 9;

{
    is_bel_output(q["Bel"], q["Bel"]);
    is_bel_output(q[""], "nil");
    is_bel_output(q[(cons \\s "tring")], q["string"]);
    is_bel_output(q[(cons \\s \\t \\r \\i \\n \\g nil)], q["string"]);
    is_bel_output(q[(cdr "max")], q["ax"]);
    my $backslash = q[\\];
    my $quote = q["];
    is_bel_output(qq[(cdr "$backslash$backslash")], "nil");
    is_bel_output(qq[(car "$backslash$quote")], q[\\"]);
    is_bel_output(qq["$backslash$backslash"], qq["$backslash$backslash"]);
    is_bel_output(qq["$backslash$quote"], qq["$backslash$quote"]);
}
