#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 25;

{
    is_bel_output("(do (set x 'hi) (where x))", "((x . hi) d)");
    is_bel_output("(do (set x 'hi) (xdr (car (where x)) 'bye) x)", "bye");
    is_bel_output("(let x 'hi (where x))", "((x . hi) d)");
    is_bel_output("(let x 'hi (xdr (car (where x)) 'bye) x)", "bye");
    is_bel_output("(bind f6ac4d 'hi (where f6ac4d))", "((f6ac4d . hi) d)");
    is_bel_output("(bind f6ac4d 'hi (xdr (car (where f6ac4d)) 'bye) f6ac4d)", "bye");
    is_bel_output("(where (car '(a b c)))", "((a b c) a)");
    is_bel_output("(where (cdr '(a b c)))", "((a b c) d)");
    is_bel_output("(where (cadr '(a b c)))", "((b c) a)");
    is_bel_output("(where (cddr '(a b c)))", "((b c) d)");
    is_bel_output("(where (caddr '(a b c)))", "((c) a)");
    is_bel_output("(where (find pair '(a b (c d) e)))", "(((c d) e) a)");
    is_bel_error("(where (find pair '(a b e)))", "'unfindable");
    is_bel_output("(where (some pair '(a b (c d) e)))", "((xs (c d) e) d)");
    is_bel_output("(where (some symbol '((a b) c d e)", "((xs c d e) d)");
    is_bel_output("(where (mem 'b '(a b c)))", "((xs b c) d)");
    is_bel_error("(where (mem 'z '(a b c)))", "'unfindable");
    is_bel_output("(where (in 'b 'a 'b 'c))", "((xs b c) d)");
    is_bel_error("(where (in 'z 'a 'b 'c))", "'unfindable");
    is_bel_output("(where (get 'b '((a . 1) (b . 2) (c . 3))))", "(((b . 2) (c . 3)) a)");
    is_bel_error("(where (get 'd '((a . 1) (b . 2) (c . 3))))", "'unfindable");
    is_bel_output("(where (get '(b) '(((a) . 1) ((b) . 2) ((c) . 3))))", "((((b) . 2) ((c) . 3)) a)");
    is_bel_error("(where (get '(b) '(((a) . 1) ((b) . 2) ((c) . 3)) id))", "'unfindable");
    is_bel_output(
        "(let q '(b) (where (get q (list '((a) . 1) (cons q 'two) '((c) . 3)) id)))",
        "((((b) . two) ((c) . 3)) a)"
    );
    is_bel_output("(where (idfn 'foo))", "((x . foo) d)");
}
