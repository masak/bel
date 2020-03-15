#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 5;

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
    is_bel_output("(c* (list (list '+ i1 i1) (list '+ i0 i1)) " .
        "(list (list '+ i1 i1) (list '+ i0 i1)))",
        "((+ (t) (t)) (+ nil (t)))");
    is_bel_output("(c* (list (list '+ i1 i1) (list '+ i0 i1)) " .
        "(list (list '- i1 i1) (list '+ i0 i1)))",
        "((- (t) (t)) (- nil (t)))");
    is_bel_output("(c* (list (list '+ i0 i1) (list '+ i1 i1)) " .
        "(list (list '+ i0 i1) (list '+ i1 i1)))",
        "((- (t) (t)) (+ nil (t)))");
    is_bel_output("(c* (list (list '+ i0 i1) (list '- i1 i1)) " .
        "(list (list '+ i0 i1) (list '- i1 i1)))",
        "((- (t) (t)) (- nil (t)))");
    is_bel_output("(c* (list (list '+ i2 '(t t t)) (list '+ i1 i1)) " .
        "(list (list '+ i1 '(t t t)) (list '- i1 i1)))",
        "((+ (t t t t t t t t t t t) (t t t t t t t t t)) " .
        "(- (t t t) (t t t t t t t t t)))");
}
