#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(pairwise id nil)", "t");
    is_bel_output("(pairwise id '(a))", "t");
    is_bel_output("(pairwise id '(a a))", "t");
    is_bel_output("(pairwise id '(a b))", "nil");
    is_bel_output("(pairwise id (list (join) (join) (join)))", "nil");
    is_bel_output("(pairwise = (list (join) (join) (join)))", "t");
    is_bel_output("(let p (join) (pairwise id `(,p ,p ,p)))", "t");
}
