#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("((lit clo nil (x) (id x nil)) nil)", "t");
    is_bel_output("((lit clo nil (x) (id x nil)) t)", "nil");
    is_bel_error("('y 'z)", "'cannot-apply");
}
