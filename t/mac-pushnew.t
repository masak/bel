#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 10;

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
    is_bel_output("(let x '(a b c) (pushnew 'a x))", "(a b c)");
    is_bel_output("(let x '(a b c) (pushnew 'a x) x)", "(a b c)");
    is_bel_output("(let x '(a b c) (pushnew 'z x))", "(z a b c)");
    is_bel_output("(let x '(a b c) (pushnew 'z x) x)", "(z a b c)");
    is_bel_output("(let x '(a b c) (pushnew 'a x =))", "(a b c)");
    is_bel_output("(let x '(a b c) (pushnew 'z x =))", "(z a b c)");
    is_bel_output("(let x '(a b c) (pushnew 'z x =))", "(z a b c)");
    is_bel_output("(let x '((a) (b) (c)) (pushnew '(a) x))", "((a) (b) (c))");
    is_bel_output("(let x '((a) (b) (c)) (pushnew '(a) x id))", "((a) (a) (b) (c))");
    is_bel_output("(withs (p '(a) x (list p '(b) '(c))) (pushnew p x id))", "((a) (b) (c))");
}
