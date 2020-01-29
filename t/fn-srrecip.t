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
    is_bel_output("(srrecip (list '+ i1 i1))", "(+ (t) (t))");
    is_bel_output("(srrecip (list '- i1 i1))", "(- (t) (t))");
    is_bel_error("(srrecip (list '+ i0 i1))", "'mistype");
    is_bel_output("(srrecip (list '+ i2 i1))", "(+ (t) (t t))");
    is_bel_output("(srrecip (list '- i2 i1))", "(- (t) (t t))");
    is_bel_output("(srrecip (list '+ i1 i2))", "(+ (t t) (t))");
    is_bel_output("(srrecip (list '+ i2 '(t t t)))", "(+ (t t t) (t t))");
    is_bel_output("(srrecip (list '- i2 i2))", "(- (t t) (t t))");
    is_bel_output("(srrecip (list '+ i2 i0))", "(+ nil (t t))");
}
