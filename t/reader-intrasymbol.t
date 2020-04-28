#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 17;

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
    is_bel_output("'a:b:c", "(compose a b c)");
    is_bel_output("'~n", "(compose no n)");
    is_bel_output("'a:~b:c", "(compose a (compose no b) c)");
    is_bel_output("'~=", "(compose no =)");
    is_bel_output("'~~z", "(compose no (compose no z))");
    is_bel_output("'~<", "(compose no <)");
    is_bel_output("'~", "no");
    is_bel_output("'~~", "(compose no no)");
    is_bel_output("'for|2", "(t for 2)");
    is_bel_output("'a.b", "(a b)");
    is_bel_output("'a!b", "(a (quote b))");
    is_bel_output("'c|isa!cont", "(t c (isa (quote cont)))");
    is_bel_output("'(id 2.x 3.x)", "(id (2 x) (3 x))");
    is_bel_output("'a!b.c", "(a (quote b) c)");
    is_bel_output("'!a", "(upon (quote a))");
    is_bel_output("(let x '(a . b) (map .x (list car cdr)))", "(a b)");
    is_bel_output("'x|~f:g!a", "(t x ((compose (compose no f) g) (quote a)))");
}
