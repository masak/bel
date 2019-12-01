#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 10;

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
    is_bel_output("(no nil)", "t");
    is_bel_output("(no 'nil)", "t");
    is_bel_output("(no '())", "t");
    is_bel_output("(no t)", "nil");
    is_bel_output("(no 'x)", "nil");
    is_bel_output("(no \\c)", "nil");
    is_bel_output("(no '(nil))", "nil");
    is_bel_output("(no '(a . b))", "nil");
    is_bel_output("(no no)", "nil");
    is_bel_output("(no (no no))", "t");
}