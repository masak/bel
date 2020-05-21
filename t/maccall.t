#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

{
    is_bel_output("((lit mac (lit clo nil (x) (list 'cons nil x))) 'a)", "(nil . a)");
    is_bel_output("((lit mac (lit clo nil (x) (list 'cons nil x))) 'b)", "(nil . b)");
}
