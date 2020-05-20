#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output(q[(split (is \\a) "frantic")], q[("fr" "antic")]);
    is_bel_output("(split no '(a b nil))", "((a b) (nil))");
    is_bel_output("(split no '(a b c))", "((a b c) nil)");
    is_bel_output(q[(split (is \\i) "frantic" "quo")], q[("quofrant" "ic")]);
}
