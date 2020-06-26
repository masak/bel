#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("(bqex nil nil)", "(nil nil)");
    is_bel_output("(bqex \\c nil)", "((quote \\c) nil)");
    is_bel_output("(bqex '(comma x) nil)", "(x t)");
    is_bel_output("(bqex '(comma-at x) nil)", "((splice x) t)");
    is_bel_output("(bqex '(bquote x) nil)", "((quote (bquote x)) nil)");
    is_bel_output("(bqex '(a b c) nil)", "((quote (a b c)) nil)");
    is_bel_output("(bqex '(a (comma x) c) nil)", "((cons (quote a) (cons x (quote (c)))) t)");
    is_bel_output("(bqex '(a (comma-at x) c) nil)", "((cons (quote a) (append (spa x) (quote (c)))) t)");
}
