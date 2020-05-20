#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

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
