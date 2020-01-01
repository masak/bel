#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 5;

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
    is_bel_output(q["Bel"], q["Bel"]);
    is_bel_output(q[""], q[nil]);
    is_bel_output(q[(cons \\s "tring")], q["string"]);
    is_bel_output(q[(cons \\s \\t \\r \\i \\n \\g nil)], q["string"]);
    is_bel_output(q[(cdr "max")], q["ax"]);
}
