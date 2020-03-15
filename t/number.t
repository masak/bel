#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 43;

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
    is_bel_output("(lit num (+ nil (t)) (+ nil (t)))", "0");
    is_bel_output("(lit num (+ (t) (t)) (+ nil (t)))", "1");
    is_bel_output("(lit num (- (t) (t)) (+ nil (t)))", "-1");
    is_bel_output("(lit num (+ (t t) (t)) (+ nil (t)))", "2");
    is_bel_output("(lit num (+ (t) (t t)) (+ nil (t)))", "1/2");
    is_bel_output("(lit num (- (t) (t t)) (+ nil (t)))", "-1/2");
    is_bel_output("(lit num (+ nil (t)) (+ (t) (t)))", "+i");
    is_bel_output("(lit num (+ nil (t)) (- (t) (t)))", "-i");
    is_bel_output("(lit num (+ (t t) (t)) (+ (t t t) (t)))", "2+3i");
    is_bel_output("(lit num (- (t t) (t)) (+ (t t t) (t)))", "-2+3i");
    is_bel_output("(lit num (+ (t t) (t)) (- (t t t) (t)))", "2-3i");
    is_bel_output("(lit num (- (t t) (t)) (- (t t t) (t)))", "-2-3i");
    is_bel_output("(lit num (+ (t t t) (t t)) (+ (t) (t t t t)))", "3/2+1/4i");
    is_bel_output("0", "0");
    is_bel_output("1", "1");
    is_bel_output("-1", "-1");
    is_bel_output("5", "5");
    is_bel_output("12", "12");
    is_bel_output("+i", "+i");
    is_bel_output("-i", "-i");
    is_bel_output("+1i", "+i");
    is_bel_output("-1i", "-i");
    is_bel_output("+3i", "+3i");
    is_bel_output("-4i", "-4i");
    is_bel_output("0+0i", "0");
    is_bel_output("0+i", "+i");
    is_bel_output("0+1i", "+i");
    is_bel_output("0-i", "-i");
    is_bel_output("0-1i", "-i");
    is_bel_output("1+i", "1+i");
    is_bel_output("-2+1i", "-2+i");
    is_bel_output("+3-2i", "3-2i");
    is_bel_output("-4-i", "-4-i");
    is_bel_output("1/2", "1/2");
    is_bel_output("3/4-1/2i", "3/4-1/2i");
    is_bel_output("2/4", "1/2");
    is_bel_output("-3/9", "-1/3");
    is_bel_output("0/5", "0");
    is_bel_output("-0/3", "0");
    is_bel_output("2.5", "5/2");
    is_bel_output(".1", "1/10");
    is_bel_output("2.5/3", "5/6");
    is_bel_output("1.2/.3", "4");
}
