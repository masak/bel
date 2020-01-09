#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 3;

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
    is_bel_output("(in 'e 'x 'y 'z)", "nil");
    is_bel_output("(in 'b 'a 'b 'c)", "(b c)");
    is_bel_output("(in nil 'a nil 'c)", "(nil c)");
}
