#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(snap nil nil)", "(nil nil)");
    is_bel_output("(snap nil '(a b c))", "(nil (a b c))");
    is_bel_output("(snap '(x) '(a b c))", "((a) (b c))");
    is_bel_output("(snap '(x y z w) '(a b c))", "((a b c nil) nil)");
    is_bel_output("(snap '(x) '(a b c) '(d e))", "((d e a) (b c))");
}
