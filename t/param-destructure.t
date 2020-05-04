#!perl -w
# -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 4;

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
    is_bel_output("((lit clo nil ((a b c)) c) '(a b c))", "c");
    is_bel_error("((lit clo nil ((a b c)) c) 'not-a-list)", "'atom-arg");
    is_bel_output("((fn ((a b c)) c) '(a b c))", "c");
    is_bel_error("((fn ((a b c)) c) 'not-a-list)", "'atom-arg");
}
