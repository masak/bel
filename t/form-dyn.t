#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 6;

sub is_bel_output {
    my ($expr, $expected_output) = @_;

    my $actual_output = "";
    my $b = Language::Bel->new({ output => sub {
        my ($string) = @_;
        $actual_output = "$actual_output$string";
    } });
    $b->eval($expr);

    is($actual_output, $expected_output, "$expr ==> $expected_output");
}

sub is_bel_error {
    my ($expr, $expected_error) = @_;

    my $b = Language::Bel->new({ output => undef });
    eval {
        $b->eval($expr);
    };

    my $actual_error = $@;
    $actual_error =~ s/\n$//;
    is($actual_error, $expected_error, "$expr ==> ERROR[$expected_error]");
}

{
    is_bel_error("(let f (fn () d) (f))", "('unboundb d)");
    is_bel_output("(let f (fn () d) (dyn d 'hai (f)))", "hai");
    is_bel_output("(dyn d 'yes d)", "yes");
    is_bel_output("(dyn d 'one (cons (dyn d 'two d) d))", "(two . one)");
    is_bel_output("(let v 'lexical (dyn v 'dynamic v))", "dynamic");
    is_bel_output("(dyn v 'dynamic (let v 'lexical v))", "dynamic");
}
