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
    is_bel_output("(adjoin 'a '(a b c))", "(a b c)");
    is_bel_output("(adjoin 'z '(a b c))", "(z a b c)");
    is_bel_output("(adjoin 'a '(a b c) =)", "(a b c)");
    is_bel_output("(adjoin 'z '(a b c) =)", "(z a b c)");
    is_bel_output("(adjoin '(a) '((a) (b) (c)))", "((a) (b) (c))");
    is_bel_output("(adjoin '(a) '((a) (b) (c)) id)", "((a) (a) (b) (c))");
    is_bel_output("(let p '(a) (adjoin p (list p '(b) '(c)) id))", "((a) (b) (c))");
}
