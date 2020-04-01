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
    is_bel_output("(pos 'b '(a b c))", "2");
    is_bel_output("(pos 'x '(w y z))", "nil");
    is_bel_output("(pos 'b '(a b c b b))", "2");
    is_bel_output("(pos '() '(n n () n))", "3");
    is_bel_output("(pos '(x) '(n n (x) n) id)", "nil");
    is_bel_output("(let p '(x) (pos p '(n n (x) n) id))", "nil");
    is_bel_output("(let p '(x) (pos p (list 'n 'n p 'n) id))", "3");
}
