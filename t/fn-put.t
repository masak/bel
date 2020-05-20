#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

{
    is_bel_output("(put 'a 'x nil)", "((a . x))");
    is_bel_output("(put 'a 'x '((b . y) (c . z)))", "((a . x) (b . y) (c . z))");
    is_bel_output("(put 'a 'x '((b . y) (a . w)))", "((a . x) (b . y))");
    is_bel_output("(put (join) 'x (list '(b . y) (cons (join) 'w)))", "(((nil) . x) (b . y))");
    is_bel_output("(put (join) 'x (list '(b . y) (cons (join) 'w)) id)", "(((nil) . x) (b . y) ((nil) . w))");
}
