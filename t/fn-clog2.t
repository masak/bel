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
    is_bel_output("(clog2 0)", "1");
    is_bel_output("(clog2 1)", "1");
    is_bel_output("(clog2 2)", "1");
    is_bel_output("(clog2 3)", "2");
    is_bel_output("(clog2 4)", "2");
    is_bel_output("(clog2 7)", "3");
    is_bel_output("(clog2 8)", "3");
    is_bel_output("(clog2 11)", "4");
}
