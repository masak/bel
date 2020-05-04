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
    is_bel_output("((lit clo nil (x) (id x nil)) nil)", "t");
    is_bel_output("((lit clo nil (x) (id x nil)) t)", "nil");
    is_bel_error("('y 'z)", "'cannot-apply");
}
