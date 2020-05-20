#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output(q[(keep [id _ \\a] "abracadabra")], q["aaaaa"]);
    is_bel_output(q[(keep [id _ 'b] '(a b c b a b))], "(b b b)");
    is_bel_output(q[(keep [id _ 'b] '(a c a))], "nil");
    is_bel_output(q[(keep [id _ 'x] nil)], "nil");
}
