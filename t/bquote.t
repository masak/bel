#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 15;

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

sub is_bel_error {
    my ($expr, $expected_error) = @_;

    eval {
        $b->eval($expr);
    };

    my $actual_error = $@;
    $actual_error =~ s/\n$//;
    is($actual_error, $expected_error, "$expr ==> ERROR[$expected_error]");
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
    is_bel_error(",x", "comma-outside-backquote");
    is_bel_error("((fn (x) ,x) 'a)", "comma-outside-backquote");
    is_bel_error(q|(nil ,@x)|, "comma-at-outside-backquote");
    is_bel_error(q|((fn (x) (nil ,@x)) 'a)|, "comma-at-outside-backquote");
    is_bel_error(q|`,@x|, "comma-at-outside-list");
    is_bel_error(q|((fn (x) `,@x) 'a)|, "comma-at-outside-list");
}
