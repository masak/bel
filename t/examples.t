#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 36;

my $actual_output = "";
my $b = Language::Bel->new({ output => sub {
    my ($string) = @_;
    $actual_output = "$actual_output$string";
} });

sub is_bel_output {
    my ($expr, $expected_output) = @_;

    $actual_output = "";
    $b->eval($expr);

    is($actual_output, $expected_output, "$expr ==> $expected_output");
}

sub is_bel_error {
    my ($expr, $expected_error) = @_;

    eval {
        $b->eval($expr);
    };

    my $actual_error = $@;
    $actual_error =~ s/\n$//;
    is($actual_error, $expected_error, "$expr ==> ERROR[$expected_error]");
}

sub bel_todo {
    my ($expr, $expected_output, $expected_todo_error) = @_;

    $expected_todo_error ||= "";
    $actual_output = "";
    eval {
        $b->eval($expr);
    };

    my $error = $@;
    $error =~ s/\n$//;
    if (!$error && $actual_output eq $expected_output) {
        ok(0, "UNEXPECTED SUCCESS $expr ==> $expected_output");
    }
    else {
        my $message = $error eq $expected_todo_error
            ? "'$error'"
            : $error
                ? "Expected '$expected_todo_error', got '$error'"
                : "Expected '$expected_output', got '$actual_output'";
        ok(
            $error && $error eq $expected_todo_error || !$error && $actual_output ne $expected_output,
            "TODO $expr ($message)"
        );
    }
}

{
    is_bel_output("(cons 'a 'b '(c d e))", "(a b c d e)");
    is_bel_output(q[(cons \h "ello")], q["hello"]);
    is_bel_output("(set w '(a (b c) d (e f)))", "(a (b c) d (e f))");
    is_bel_output("(find pair w)", "(b c)");
    is_bel_output("(pop (find pair w))", "b");
    is_bel_output("w", "(a (c) d (e f))");
    bel_todo(q[(dedup:sort < "abracadabra")], q["abcdr"], "('unboundb dedup)");
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
    # TODO: `sym` not implemented
    bel_todo(q[(let m (macro (x) (sym (append (nom x) "ness"))) (set (m good) 10))], "10", "('unboundb sym)");
    # TODO: goes with the previous one
    bel_todo("goodness", "10", "('unboundb goodness)");
    # TODO: can't apply macros yet
    bel_todo("(apply or '(t nil))", "t", "'unapplyable");
    # TODO: `best` not implemented
    bel_todo("(best (of > len) '((a b) (a b c d) (a) (a b c)))", "(a b c d)", "('unboundb best)");
    # TODO: `!3` syntax not implemented
    bel_todo("(!3 (part + 2))", "5", "('unboundb part)");
    # TODO: `to` not implemented
    bel_todo(q[(to "testfile" (print 'hello))], "nil", "('unboundb to)");
    # TODO: `from` not implemented
    bel_todo(q[(from "testfile" (read))], "hello", "('unboundb from)");
    # TODO: `table` not implemented
    bel_todo("(set y (table))", "(lit tab)", "('unboundb table)");
    bel_todo("(set y!a 1 y!b 2)", "2", "('unboundb y)");
    # TODO: goes with the previous one
    bel_todo("(map y '(a b))", "(1 2)", "('unboundb y)");
    # TODO: goes with the previous one
    bel_todo("(map ++:y '(a b))", "(2 3)", "('unboundb y)");
    bel_todo("y!b", "3", "('unboundb y)");
    # TODO: `array` not implemented
    bel_todo("(set z (array '(2 2) 0))", "(lit arr (lit arr 0 0) (lit arr 0 0))", "('unboundb array)");
    # TODO: goes with the previous one
    bel_todo("(z 1 1)", "0", "('unboundb z)");
    # TODO: goes with the previous one
    bel_todo("(for x 1 2 (for y 1 2 (set (z x y) (+ (* x 10) y))))", "nil", "('unboundb for)");
    # TODO: goes with the previous one
    bel_todo("(z 1 1)", "11", "('unboundb z)");
    # TODO: goes with the previous one
    bel_todo("(swap (z 1) (z 2))", "(lit arr 11 12)", "('unboundb swap)");
    # TODO: goes with the previous one
    bel_todo("(z 1 1)", "21", "('unboundb z)");
}

