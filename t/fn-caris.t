#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(caris nil nil)", "nil");
    is_bel_output("(caris '(a b c) 'a)", "t");
    is_bel_output("(caris '(a b c) 'b)", "nil");
    is_bel_output("(caris '((x y z) b c) '(x y z))", "t");
    is_bel_output("(caris '((x y z) b c) '(x y z) id)", "nil");
    is_bel_output("(let p '(x y z) (caris `(,p b c) p id))", "t");
}
