#!perl -w
# -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("((lit clo nil ((a b c)) c) '(a b c))", "c");
    is_bel_error("((lit clo nil ((a b c)) c) 'not-a-list)", "'atom-arg");
    is_bel_output("((fn ((a b c)) c) '(a b c))", "c");
    is_bel_error("((fn ((a b c)) c) 'not-a-list)", "'atom-arg");
}
