#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 3;

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
    bel_todo("~~odd", "t", "('unboundb odd)");
    is_bel_output(
        "(with (odd (fn (n) (~int (/ n 2))) x '(1 2 3 4 5)) (clean odd x))",
        "(2 4)"
    );
    is_bel_output(
        "(with (odd (fn (n) (~int (/ n 2))) x '(1 2 3 4 5)) (clean odd x) x)",
        "(2 4)"
    );
}
