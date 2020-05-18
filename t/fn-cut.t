#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 4;

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
    is_bel_output(q[(cut "foobar" 2 4)], q["oob"]);
    is_bel_output(q[(cut "foobar" 2 -1)], q["ooba"]);
    is_bel_output(q[(cut "foobar" 2)], q["oobar"]);
    is_bel_output(q[(cut "foobar")], q["foobar"]);
}
