#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 14;

{
    is_bel_output("(runs [= _ 1] '(1 1 0 0 0 1 1 1 0)) ", "((1 1) (0 0 0) (1 1 1) (0))");
    is_bel_output("(runs [= _ 1] '()) ", "nil");
    is_bel_output("(runs [= _ 1] '(1)) ", "((1))");
    is_bel_output("(runs [= _ 1] '(0)) ", "((0))");
    is_bel_output("(runs [= _ 1] '(1 0)) ", "((1) (0))");
    is_bel_output("(runs [= _ 1] '(0 1)) ", "((0) (1))");
    is_bel_output("(runs [= _ 1] '(1) nil) ", "(nil (1))");
    is_bel_output("(runs [= _ 1] '(1) t) ", "((1))");
    is_bel_output("(runs [= _ 1] '(0) nil) ", "((0))");
    is_bel_output("(runs [= _ 1] '(0) t) ", "(nil (0))");
    is_bel_output("(runs [= _ 1] '(1 0) nil) ", "(nil (1) (0))");
    is_bel_output("(runs [= _ 1] '(1 0) t) ", "((1) (0))");
    is_bel_output("(runs [= _ 1] '(0 1) nil) ", "((0) (1))");
    is_bel_output("(runs [= _ 1] '(0 1) t) ", "(nil (0) (1))");
}
