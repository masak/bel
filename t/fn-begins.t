#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 12;

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
    is_bel_output("(begins nil nil)", "t");
    is_bel_output("(begins '(a b c) nil)", "t");
    is_bel_output("(begins '(a b c) '(a))", "t");
    is_bel_output("(begins '(a b c) '(x))", "nil");
    is_bel_output("(begins '(a b c) '(a b))", "t");
    is_bel_output("(begins '(a b c) '(a y))", "nil");
    is_bel_output("(begins '(a b c) '(a b c))", "t");
    is_bel_output("(begins '(a b c) '(a b z))", "nil");
    is_bel_output("(let p (join) (begins (list p) (list p)))", "t");
    is_bel_output("(let p (join) (begins (list p) (list (join))))", "t");
    is_bel_output("(let p (join) (begins (list p) (list p) id))", "t");
    is_bel_output("(let p (join) (begins (list p) (list (join)) id))", "nil");
}
