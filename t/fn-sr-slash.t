#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 9;

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
    is_bel_output("(sr/ (list '+ i1 i1) (list '+ i1 i1))", "(+ (t) (t))");
    is_bel_output("(sr/ (list '+ i1 i1) (list '- i1 i1))", "(- (t) (t))");
    is_bel_output("(sr/ (list '+ i0 i1) (list '+ i2 i1))", "(+ nil (t t))");
    is_bel_output("(sr/ (list '+ i2 i1) (list '+ i2 i1))",
        "(+ (t t) (t t))");
    is_bel_output("(sr/ (list '+ i1 i1) (list '- i2 i1))", "(- (t) (t t))");
    is_bel_output("(sr/ (list '+ i1 i2) (list '+ i1 i2))",
        "(+ (t t) (t t))");
    is_bel_output("(sr/ (list '+ i2 '(t t t)) (list '+ '(t t t) i2))",
        "(+ (t t t t) (t t t t t t t t t))");
    is_bel_output("(sr/ (list '- i2 i2) (list '+ i1 i2))",
        "(- (t t t t) (t t))");
    is_bel_output("(sr/ (list '+ i2 i0) (list '+ '(t t t) i2))",
        "(+ (t t t t) nil)");
}
