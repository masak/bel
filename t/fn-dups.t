#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 6;

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
    is_bel_output("(dups nil)", "nil");
    is_bel_output("(dups '(a b c))", "nil");
    is_bel_output("(dups '(a b b c))", "(b)");
    is_bel_output("(dups '(a nil b c nil))", "(nil)");
    is_bel_output("(dups '(1 2 3 4 3 2))", "(2 3)");
    is_bel_output(q[(dups "abracadabra")], q["abr"]);
}
