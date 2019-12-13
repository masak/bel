#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 9;

sub is_bel_output {
    my ($expr, $expected_output) = @_;

    my $actual_output = "";
    my $b = Language::Bel->new({ output => sub {
        my ($string) = @_;
        $actual_output = "$actual_output$string";
    } });
    $b->eval($expr);

    is($actual_output, $expected_output, "$expr ==> $expected_output");
}

{
    is_bel_output("`x", "x");
    is_bel_output("`(y z)", "(y z)");
    is_bel_output("((fn (x) `(a ,x)) 'b)", "(a b)");
    is_bel_output("((fn (y) `(,y d)) 'c)", "(c d)");
    is_bel_output("((fn (x) `(a . ,x)) 'b)", "(a . b)");
    is_bel_output("((fn (y) `(,y . d)) 'c)", "(c . d)");
    is_bel_output(q|((fn (x) `(a ,@x)) '(b1 b2 b3))|, "(a b1 b2 b3)");
    is_bel_output(q|((fn (y) `(,@y d)) '(c1 c2 c3))|, "(c1 c2 c3 d)");
    is_bel_output(q|((fn (y) `(,@y . d)) '(c1 c2 c3))|, "(c1 c2 c3 . d)");
}
