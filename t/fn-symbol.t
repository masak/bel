#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 5;

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

{
    is_bel_output("(symbol 'x)", "t");
    is_bel_output("(symbol nil)", "t");
    is_bel_output("(symbol '(a))", "nil");
    is_bel_output("(symbol (join))", "nil");
    is_bel_output("(symbol \\c)", "nil");
}
