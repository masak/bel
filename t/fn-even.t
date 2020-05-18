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
    is_bel_output("(even 0)", "t");
    is_bel_error("(even \\x)", "cdr-on-atom");
    is_bel_output("(even -1)", "nil");
    is_bel_error("(even \\0)", "cdr-on-atom");
    is_bel_output("(even 1/2)", "nil");
    is_bel_output("(even 4/2)", "t");
    is_bel_output("(even 3)", "nil");
    is_bel_output("(even 4)", "t");
}
