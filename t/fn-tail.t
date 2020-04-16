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
    is_bel_output("(tail idfn nil)", "nil");
    is_bel_output("(tail car '(a b c))", "(a b c)");
    is_bel_output("(tail car '(nil b c))", "(b c)");
    is_bel_output("(tail no:cdr '(a b c))", "(c)");
    is_bel_output(q!(tail [caris _ \-] "non-nil")!, q["-nil"]);
}