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
    is_bel_error("lock", "('unboundb lock)");
    is_bel_error("(let f (fn () lock) (f))", "('unboundb lock)");
    is_bel_output("(let f (fn () lock) (atomic (f)))", "t");
    is_bel_output("(atomic 'hi)", "hi");
    is_bel_output("(atomic lock)", "t");
    is_bel_output("(atomic 'no 'but lock)", "t");
    is_bel_output("(atomic (cons (atomic lock) lock))", "(t . t)");
    is_bel_output("(let lock 'lexical (atomic lock))", "t");
    is_bel_output("(atomic (let lock 'lexical lock))", "t");
}
