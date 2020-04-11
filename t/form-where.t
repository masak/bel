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

{
    is_bel_output("(do (set x 'hi) (where x))", "((x . hi) d)");
    is_bel_output("(do (set x 'hi) (xdr (car (where x)) 'bye) x)", "bye");
    is_bel_output("(let x 'hi (where x))", "((x . hi) d)");
    is_bel_output("(let x 'hi (xdr (car (where x)) 'bye) x)", "bye");
    is_bel_output("(bind f6ac4d 'hi (where f6ac4d))", "((f6ac4d . hi) d)");
    is_bel_output("(bind f6ac4d 'hi (xdr (car (where f6ac4d)) 'bye) f6ac4d)", "bye");
    is_bel_output("(where (car '(a b c)))", "((a b c) a)");
    is_bel_output("(where (cdr '(a b c)))", "((a b c) d)");
}
