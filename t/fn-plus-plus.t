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
    is_bel_output("(let x 1 (++ x))", "2");
    is_bel_output("(let x 1.5 (++ x))", "5/2");
    is_bel_output("(let x -3+i (++ x))", "-2+i");
    is_bel_output("(let x 1 (++ x) x)", "2");
    is_bel_output("(let x 1 (++ x 3))", "4");
    is_bel_output("(let x 1 (++ x 3) x)", "4");
    is_bel_output("(let l '(1 1 1) (++ (cadr l)))", "2");
    is_bel_output("(let l '(1 1 1) (++ (cadr l)) l)", "(1 2 1)");
    is_bel_output("(bind f6ac4d 2 (++ f6ac4d) f6ac4d)", "3");
    is_bel_output("(bind f6ac4d 3 (++ f6ac4d 3) f6ac4d)", "6");
    is_bel_output("(let l '(1 2 3) (++ (find [= _ 2] l)) l)", "(1 3 3)");
    is_bel_error("(let l '(1 2 3) (++ (find [= _ 0] l)) l)", "'unfindable");
    is_bel_output("(let l '(1 2 3) (++ (find [= _ 2] l) 2) l)", "(1 4 3)");
    is_bel_error("(let l '(1 2 3) (++ (find [= _ 0] l) 2) l)", "'unfindable");
    is_bel_output(
        "(let kvs '((a . 1) (b . 2) (c . 3)) (++ (cdr:get 'b kvs)) kvs)",
        "((a . 1) (b . 3) (c . 3))"
    );
    is_bel_output(
        "(let kvs '(((a) . 1) ((b) . 2) ((c) . 3)) (++ (cdr:get '(b) kvs)) kvs)",
        "(((a) . 1) ((b) . 3) ((c) . 3))"
    );
}
