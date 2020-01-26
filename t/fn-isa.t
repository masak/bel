#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 8;

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
    is_bel_output("((isa 'clo) (fn (x) x))", "t");
    is_bel_output("((isa 'clo) [_])", "t");
    is_bel_output("((isa 'clo) idfn)", "t");
    is_bel_output("((isa 'prim) car)", "t");
    is_bel_output("((isa 'clo) nil)", "nil");
    is_bel_output("((isa 'clo) 'c)", "nil");
    is_bel_output("((isa 'clo) '(a b c))", "nil");
    is_bel_output("((isa 'mac) def)", "t");
}
