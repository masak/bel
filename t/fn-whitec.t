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
    is_bel_output("(~~whitec \\sp)", "t");
    is_bel_output("(~~whitec \\lf)", "t");
    is_bel_output("(~~whitec \\tab)", "t");
    is_bel_output("(~~whitec \\cr)", "t");
    is_bel_output("(~~whitec \\a)", "nil");
    is_bel_output("(~~whitec \\b)", "nil");
    is_bel_output("(~~whitec \\x)", "nil");
    is_bel_output("(~~whitec \\1)", "nil");
}
