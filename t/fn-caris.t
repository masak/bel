#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 6;

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
    is_bel_output("(caris nil nil)", "nil");
    is_bel_output("(caris '(a b c) 'a)", "t");
    is_bel_output("(caris '(a b c) 'b)", "nil");
    is_bel_output("(caris '((x y z) b c) '(x y z))", "t");
    is_bel_output("(caris '((x y z) b c) '(x y z) id)", "nil");
    is_bel_output("(let p '(x y z) (caris `(,p b c) p id))", "t");
}
