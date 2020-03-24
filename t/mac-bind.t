#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 7;

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
    is_bel_error("(let f (fn () d) (f))", "('unboundb d)");
    is_bel_output("(let f (fn () d) (bind d 'hai (f)))", "hai");
    is_bel_output("(bind d 'yes d)", "yes");
    is_bel_output("(bind d 'yes 'no 'but d)", "yes");
    is_bel_output("(bind d 'one (cons (bind d 'two d) d))", "(two . one)");
    is_bel_output("(let v 'lexical (bind v 'dynamic v))", "dynamic");
    is_bel_output("(bind v 'dynamic (let v 'lexical v))", "dynamic");
}
