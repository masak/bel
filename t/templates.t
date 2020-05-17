#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 9;

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
    is_bel_output("templates", "(lit tab)");
    is_bel_output("(tem point x 0 y 0)", "((x lit clo nil nil 0) (y lit clo nil nil 0))");
    is_bel_output("(make point)", "(lit tab (x . 0) (y . 0))");
    is_bel_output("(make point x 1 y 5)", "(lit tab (x . 1) (y . 5))");
    is_bel_output("(let p (make point) p!x)", "0");
    is_bel_output("(let p (make point) (++ p!x))", "1");
    is_bel_output("(let p (make point) (++ p!x) p!x)", "1");
    bel_todo("(let p (make point x 1) (swap p!x p!y) p)", "(lit tab (x . 0) (y . 1))", "('unboundb swap)");
    is_bel_output(
        "(with (p (make point y 1) q (make point x 1 y 5) above (of > !y)) (above q p (make point)))",
        "t",
    );
}
