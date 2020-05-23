#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 36;

{
    is_bel_output("(cons 'a 'b '(c d e))", "(a b c d e)");
    is_bel_output(q[(cons \h "ello")], q["hello"]);
    is_bel_output("(set w '(a (b c) d (e f)))", "(a (b c) d (e f))");
    is_bel_output("(find pair w)", "(b c)");
    is_bel_output("(pop (find pair w))", "b");
    is_bel_output("w", "(a (c) d (e f))");
    bel_todo(q[(dedup:sort < "abracadabra")], q["abcdr"], "('unboundb chars)");
    is_bel_output("(+ .05 19/20)", "1");
    is_bel_output("(map (upon 2 3) (list + - * /))", "(5 -1 6 2/3)");
    is_bel_output("(let x 'a (cons x 'b))", "(a . b)");
    is_bel_output("(with (x 1 y 2) (+ x y))", "3");
    is_bel_output("(let ((x y) . z) '((a b) c) (list x y z))", "(a b (c))");
    is_bel_output("((fn (x) (cons x 'b)) 'a)", "(a . b)");
    is_bel_output("((fn (x|symbol) (cons x 'b)) 'a)", "(a . b)");
    is_bel_error("((fn (x|int) (cons x 'b)) 'a)", "'mistype");
    is_bel_output("((fn (f x|f) (cons x 'b)) symbol 'a)", "(a . b)");
    is_bel_output("((macro (v) `(set ,v 7)) x)", "7");
    is_bel_output("x", "7");
    is_bel_output(q[(let m (macro (x) (sym (append (nom x) "ness"))) (set (m good) 10))], "10");
    is_bel_output("goodness", "10");
    is_bel_output("(apply or '(t nil))", "t");
    is_bel_output("(best (of > len) '((a b) (a b c d) (a) (a b c)))", "(a b c d)");
    is_bel_output("(!3 (part + 2))", "5");
    # TODO: `to` not implemented
    bel_todo(q[(to "testfile" (print 'hello))], "nil", "('unboundb to)");
    # TODO: `from` not implemented
    bel_todo(q[(from "testfile" (read))], "hello", "('unboundb from)");
    is_bel_output("(set y (table))", "(lit tab)");
    is_bel_output("(set y!a 1 y!b 2)", "2");
    is_bel_output("(map y '(a b))", "(1 2)");
    is_bel_output("(map ++:y '(a b))", "(2 3)");
    is_bel_output("y!b", "3");
    is_bel_output("(set z (array '(2 2) 0))", "(lit arr (lit arr 0 0) (lit arr 0 0))");
    is_bel_output("(z 1 1)", "0");
    is_bel_output("(for x 1 2 (for y 1 2 (set (z x y) (+ (* x 10) y))))", "nil");
    is_bel_output("(z 1 1)", "11");
    is_bel_output("(swap (z 1) (z 2))", "(lit arr 11 12)");
    is_bel_output("(z 1 1)", "21");
}
