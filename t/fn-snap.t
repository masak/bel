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
    is_bel_output("(snap nil nil)", "(nil nil)");
    is_bel_output("(snap nil '(a b c))", "(nil (a b c))");
    is_bel_output("(snap '(x) '(a b c))", "((a) (b c))");
    is_bel_output("(snap '(x y z w) '(a b c))", "((a b c nil) nil)");
    is_bel_output("(snap '(x) '(a b c) '(d e))", "((d e a) (b c))");
}
