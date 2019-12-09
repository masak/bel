#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 2;

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
    is_bel_output("((lit mac (lit clo nil (x) (list 'cons nil x))) 'a)", "(nil . a)");
    is_bel_output("((lit mac (lit clo nil (x) (list 'cons nil x))) 'b)", "(nil . b)");
}
