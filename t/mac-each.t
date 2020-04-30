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
    is_bel_output("(let L '() (each n '(1 2 3) (push (inc n) L)) L)", "(4 3 2)");
    is_bel_output("(let L '() (each n '() (push (inc n) L)) L)", "nil");
    is_bel_output("(let L '((a) (b) (c)) (each e L (xar e 'z)) L)", "((z) (z) (z))");
    is_bel_output("(let x nil (each y '(a b c) (push y x)) x)", "(c b a)");
}
