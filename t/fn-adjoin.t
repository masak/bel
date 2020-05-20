#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(adjoin 'a '(a b c))", "(a b c)");
    is_bel_output("(adjoin 'z '(a b c))", "(z a b c)");
    is_bel_output("(adjoin 'a '(a b c) =)", "(a b c)");
    is_bel_output("(adjoin 'z '(a b c) =)", "(z a b c)");
    is_bel_output("(adjoin '(a) '((a) (b) (c)))", "((a) (b) (c))");
    is_bel_output("(adjoin '(a) '((a) (b) (c)) id)", "((a) (a) (b) (c))");
    is_bel_output("(let p '(a) (adjoin p (list p '(b) '(c)) id))", "((a) (b) (c))");
}
