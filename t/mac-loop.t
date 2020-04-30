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
    is_bel_output("(let L nil (loop x 1 (+ x 1) (i< (srnum:numr x) (srnum:numr 5)) (push x L)) L)", "(4 3 2 1)");
    is_bel_output("(let L nil (loop x 1 (+ x 1) (i< (srnum:numr x) (srnum:numr 1)) (push x L)) L)", "nil");
}
