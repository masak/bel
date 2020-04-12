#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 16;

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

{
    is_bel_output("(set x 'foo)", "foo");
    is_bel_output("(set y)", "t");
    is_bel_output("(do (set x 'foo) (set x 'bar))", "bar");
    is_bel_output("(do (set x 'foo x 'bar) x)", "bar");
    is_bel_output("(do (set x 'foo) (set x 'bar) x)", "bar");
    is_bel_output("(do (set y) y)", "t");
    is_bel_output("(set x 'foo x 'bar)", "bar");
    is_bel_output("(set x 'foo y 'bar)", "bar");
    is_bel_output("(let x 'hi (set x 'bye) x)", "bye");
    is_bel_output("(bind f6ac4d 'hi (set f6ac4d 'bye) f6ac4d)", "bye");
    is_bel_output("(let l '(a b (c d) e) (set (find pair l) 'cd) l)", "(a b cd e)");
    is_bel_error("(set (find pair '(a b e)) 'z)", "'unfindable");
    is_bel_output(
        "(let kvs '((a . 1) (b . 2) (c . 3)) (set (cdr:get 'b kvs) 5) kvs)",
        "((a . 1) (b . 5) (c . 3))"
    );
    is_bel_error(
        "(let kvs '((a . 1) (b . 2) (c . 3)) (set (get 'd kvs) 5))",
        "'unfindable"
    );
    is_bel_output(
        "(let kvs '(((a) . 1) ((b) . 2) ((c) . 3)) (set (cdr:get '(b) kvs) 5) kvs)",
        "(((a) . 1) ((b) . 5) ((c) . 3))"
    );
    is_bel_error(
        "(let kvs '(((a) . 1) ((b) . 2) ((c) . 3)) (set (get '(b) kvs id) 5))",
        "'unfindable"
    );
}
