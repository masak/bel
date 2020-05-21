#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 12;

{
    is_bel_output("(begins nil nil)", "t");
    is_bel_output("(begins '(a b c) nil)", "t");
    is_bel_output("(begins '(a b c) '(a))", "t");
    is_bel_output("(begins '(a b c) '(x))", "nil");
    is_bel_output("(begins '(a b c) '(a b))", "t");
    is_bel_output("(begins '(a b c) '(a y))", "nil");
    is_bel_output("(begins '(a b c) '(a b c))", "t");
    is_bel_output("(begins '(a b c) '(a b z))", "nil");
    is_bel_output("(let p (join) (begins (list p) (list p)))", "t");
    is_bel_output("(let p (join) (begins (list p) (list (join))))", "t");
    is_bel_output("(let p (join) (begins (list p) (list p) id))", "t");
    is_bel_output("(let p (join) (begins (list p) (list (join)) id))", "nil");
}
