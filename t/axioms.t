#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 31;

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
    is_bel_output("(id 'a 'a)", "t");
    is_bel_output("(id 'a 'b)", "nil");
    is_bel_output("(id 'a \\a)", "nil");
    is_bel_output("(id \\a \\a)", "t");
    is_bel_output("(id 't t)", "t");
    is_bel_output("(id nil 'nil)", "t");
    is_bel_output("(id id id)", "t");
    is_bel_output("(id id 'id)", "nil");
    is_bel_output("(id id nil)", "nil");
    is_bel_output("(id nil)", "t");
    is_bel_output("(id)", "t");
}

{
    is_bel_output("(join 'a 'b)", "(a . b)");
    is_bel_output("(join 'a)", "(a)");
    is_bel_output("(join)", "(nil)");
    is_bel_output("(join nil 'b)", "(nil . b)");
    is_bel_output("(id (join 'a 'b) (join 'a 'b))", "nil");
}

{
    is_bel_output("(car '(a . b))", "a");
    is_bel_output("(car '(a b))", "a");
    is_bel_output("(car nil)", "nil");
    is_bel_output("(car)", "nil");
    is_bel_error("(car 'atom)", "car-on-atom");
}

{
    is_bel_output("(cdr '(a . b))", "b");
    is_bel_output("(cdr '(a b))", "(b)");
    is_bel_output("(cdr nil)", "nil");
    is_bel_output("(cdr)", "nil");
    is_bel_error("(cdr 'atom)", "cdr-on-atom");
}

{
    is_bel_output("(type 'a)", "symbol");
    is_bel_output("(type \\a)", "char");
    is_bel_output("(type \\bel)", "char");
    is_bel_output("(type nil)", "symbol");
    is_bel_output("(type '(a))", "pair");
}
