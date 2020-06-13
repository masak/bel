#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 11;

{
    is_bel_output("(lookup 'foo nil nil nil)", "nil");

    # scope, globe
    is_bel_output("(lookup 'scope '((a . 1)) nil nil)", "(scope (a . 1))");
    is_bel_output("(lookup 'globe nil nil '((b . 2)))", "(globe (b . 2))");

    # global lookup (trumps scope and globe)
    is_bel_output("(lookup 'foo nil nil '((foo . 0)))", "(foo . 0)");
    is_bel_output("(lookup 'scope nil nil '((scope . 1)))", "(scope . 1)");
    is_bel_output("(lookup 'globe nil nil '((globe . 2)))", "(globe . 2)");

    # lexical lookup (trumps global lookup)
    is_bel_output("(lookup 'foo '((foo . 0)) nil nil)", "(foo . 0)");
    is_bel_output("(lookup 'foo '((foo . 1)) nil '((foo . 2)))", "(foo . 1)");

    # dynamic lookup (trumps lexical lookup)
    is_bel_output(
        "(lookup 'foo nil (list (cons (list smark 'bind '(foo . 0)) nil)) nil)",
        "(foo . 0)",
    );
    is_bel_output(
        "(lookup 'foo '((foo . 2)) (list (cons (list smark 'bind '(foo . 1)) nil)) nil)",
        "(foo . 1)",
    );
    is_bel_output(
        "(lookup 'foo nil (list (cons (list smark 'bind '(foo . 1)) '((foo . 3)))) nil)",
        "(foo . 1)",
    );
}
