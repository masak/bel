#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 8;

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
    is_bel_output("(< 2 4)", "t");
    is_bel_output("(< 5 3)", "nil");
    bel_todo("(< \\a \\c)", "t", "('unboundb chars)");
    bel_todo("(< \\d \\b)", "nil", "('unboundb chars)");
    bel_todo(q[(< "aa" "ac")], "t", "('unboundb chars)");
    bel_todo(q[(< "bc" "ab")], "nil", "('unboundb chars)");
    bel_todo("(< 'aa 'ac)", "t", "('unboundb chars)");
    bel_todo("(< 'bc 'ab)", "nil", "('unboundb chars)");
}
