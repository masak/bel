#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 4;

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
    is_bel_output("(do (def popx () (let (xa . xd) x (set x xd) xa)) (function popx))", "clo");
    is_bel_output("(do (set x '(nil nil a b c)) (len x))", "5");
    is_bel_output("((rfn self (v) (if v v (self (popx)))) (popx))", "a");
    is_bel_output("(len x)", "2");
}
