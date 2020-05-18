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
    is_bel_output("(^w 5 1)", "5");
    is_bel_output("(^w 5 0)", "1");
    is_bel_output("(^w 3 2)", "9");
    is_bel_output("(^w 2 3)", "8");
    is_bel_output("(^w 1.5 1)", "3/2");
    is_bel_output("(^w 1.5 0)", "1");
    is_bel_output("(^w 1.5 2)", "9/4");
    is_bel_error("(^w 5 -1)", "'mistype");
}
