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
    is_bel_output(qq[(tokens "the age of the essay")], qq[("the" "age" "of" "the" "essay")]);
    is_bel_output(qq[(tokens "A|B|C")], qq[("A|B|C")]);
    is_bel_output(qq[(tokens "A|B|C" \\|)], qq[("A" "B" "C")]);
    is_bel_output(qq[(tokens "A.B:C.D!E:F" (cor (is \\.) (is \\:)))], qq[("A" "B" "C" "D!E" "F")]);
}
