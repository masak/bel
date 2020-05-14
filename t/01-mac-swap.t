#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 2;

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
    is_bel_output(
        "(let (x y z) '(a b c) (swap x y z) (list x y z))",
        "(b c a)"
    );
    is_bel_output(
        "(let x '(a b c d e) (swap 2.x 4.x) x)",
        "(a d c b e)"
    );
}
