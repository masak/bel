#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 15;

{
    is_bel_output("(let x 1 (zap + x 1) x)", "2");
    is_bel_output("(let x 1 (zap + x 1))", "2");
    is_bel_output(q[(let y "Be" (zap append y "l") y)], q["Bel"]);
    is_bel_output(q[(let y "Be" (zap append y "l"))], q["Bel"]);
    is_bel_output("(let l '(a b c) (zap (fn () 'z) (cadr l)))", "z");
    is_bel_output("(let l '(a b c) (zap (fn () 'z) (cadr l)) l)", "(a z c)");
    is_bel_output("(let l '(a (b c) d) (zap cdr (find pair l)) l)", "(a (c) d)");
    is_bel_output("(let x 'hi (set x 'bye) x)", "bye");
    is_bel_output("(bind f6ac4d 'hi (zap (fn () 'bye) f6ac4d) f6ac4d)", "bye");
    is_bel_output("(let l '(a b (c d) e) (zap (fn () 'cd) (find pair l)) l)", "(a b cd e)");
    is_bel_error("(zap (fn () 'z) (find pair '(a b e)))", "'unfindable");
    is_bel_output(
        "(let kvs '((a . 1) (b . 2) (c . 3)) (zap (fn () 5) (cdr:get 'b kvs)) kvs)",
        "((a . 1) (b . 5) (c . 3))"
    );
    is_bel_error(
        "(let kvs '((a . 1) (b . 2) (c . 3)) (zap (fn () 5) (get 'd kvs)))",
        "'unfindable"
    );
    is_bel_output(
        "(let kvs '(((a) . 1) ((b) . 2) ((c) . 3)) (zap (fn () 5) (cdr:get '(b) kvs)) kvs)",
        "(((a) . 1) ((b) . 5) ((c) . 3))"
    );
    is_bel_error(
        "(let kvs '(((a) . 1) ((b) . 2) ((c) . 3)) (zap (fn () 5) (get '(b) kvs id)))",
        "'unfindable"
    );
}
