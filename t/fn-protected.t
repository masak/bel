#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(protected (list (list smark 'foo)))", "nil");
    is_bel_output("(if (protected (list (list smark 'bind))) t)", "t");
    is_bel_output("(if (protected (list (list smark 'prot))) t)", "t");
    is_bel_output("(protected (list (list (join) 'bind)))", "nil");
}
