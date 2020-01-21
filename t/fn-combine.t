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
    is_bel_output("(((combine and) atom no) nil)", "t");
    is_bel_output("(((combine and) atom no) t)", "nil");
    is_bel_output("(((combine and) atom) t)", "t");
    is_bel_output("(((combine and) atom) (join))", "nil");
    is_bel_output("(((combine and)) nil)", "t");
    is_bel_output("(((combine or) pair no) nil)", "t");
    is_bel_output("(((combine or) pair no) t)", "nil");
    is_bel_output("(((combine or) pair no) '(x y))", "t");
    is_bel_output("(((combine or) pair) (join))", "t");
    is_bel_output("(((combine or)) nil)", "nil");
}
