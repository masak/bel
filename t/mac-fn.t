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
    is_bel_output("((fn (x) (list x x)) 'a)", "(a a)");
    is_bel_output("((fn (x y) (list x y)) 'a 'b)", "(a b)");
    is_bel_output("((fn () (list 'a 'b 'c)))", "(a b c)");
    is_bel_output("((fn (x) ((fn (y) (list x y)) 'g)) 'f)", "(f g)");
    is_bel_output("((fn () 'irrelevant 'relevant))", "relevant");
    is_bel_error("((fn () (car 'atom) 'never))", "car-on-atom");
}
