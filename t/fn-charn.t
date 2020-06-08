#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(charn \\bel)", "7");
    is_bel_output("(charn \\sp)", "32");
    is_bel_output("(charn \\0)", "48");
    is_bel_output("(charn \\B)", "66");
    is_bel_output("(charn \\e)", "101");
    is_bel_output("(charn \\l)", "108");
}
