#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 7;

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
    is_bel_output("(pairwise id nil)", "t");
    is_bel_output("(pairwise id '(a))", "t");
    is_bel_output("(pairwise id '(a a))", "t");
    is_bel_output("(pairwise id '(a b))", "nil");
    is_bel_output("(pairwise id (list (join) (join) (join)))", "nil");
    is_bel_output("(pairwise = (list (join) (join) (join)))", "t");
    is_bel_output("(let p (join) (pairwise id `(,p ,p ,p)))", "t");
}
