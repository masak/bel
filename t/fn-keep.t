#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 4;

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
    is_bel_output(q[(keep [id _ \\a] "abracadabra")], q["aaaaa"]);
    is_bel_output(q[(keep [id _ 'b] '(a b c b a b))], "(b b b)");
    is_bel_output(q[(keep [id _ 'b] '(a c a))], "nil");
    is_bel_output(q[(keep [id _ 'x] nil)], "nil");
}
