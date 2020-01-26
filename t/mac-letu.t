#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 6;

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
    is_bel_output("(letu va (variable va))", "t");
    is_bel_output("(letu va va)", "((nil))");
    is_bel_output("(letu va (id vmark (car va)))", "t");
    is_bel_output("(letu (vb vc) (and (variable vb) (variable vc)))", "t");
    is_bel_output("(letu (vb vc) (list vb vc))", "(((nil)) ((nil)))");
    is_bel_output("(letu (vb vc) (and (id vmark (car vb)) (id vmark (car vc))))", "t");
}
