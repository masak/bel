#!perl -w
# -T
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
    is_bel_output("((lit clo nil ((t xs pair)) xs) (join))", "(nil)");
    is_bel_error("((lit clo nil ((t xs pair)) xs) 'a)", "'mistype");
    is_bel_output("((fn ((t xs pair)) xs) (join))", "(nil)");
    is_bel_error("((fn ((t xs pair)) xs) 'a)", "'mistype");
    is_bel_error("((fn ((o (t (x . y) [caris _ 'a]) '(a . b))) x) '(b b))",
        "'mistype");
    is_bel_output("((fn ((o (t (x . y) [caris _ 'a]) '(a . b))) x))", "a");
    is_bel_output(
        "(let srrecip (fn (s (t n [~= _ nil]) d) (list s d n)) " .
        "(srrecip '+ '(t t) '(t t t)))",
        "(+ (t t t) (t t))");
    is_bel_error(
        "(let srrecip (fn (s (t n [~= _ nil]) d) (list s d n)) " .
        "(srrecip '+ nil '(t t t)))",
        "'mistype");
}
