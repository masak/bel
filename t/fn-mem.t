#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

{
    is_bel_output("(mem 'b '(a b c))", "(b c)");
    is_bel_output("(mem 'e '(a b c))", "nil");
    is_bel_output(q[(mem \\a "foobar")], q["ar"]);
    is_bel_output("(mem '(x) '((a) b x))", "nil");
    is_bel_output("(mem '(x) '((a) b (x)))", "((x))");
    is_bel_output("(mem '(x) '((a) b (x)) id)", "nil");
    is_bel_output("(let q '(x) (mem q (list '(a) 'b q)))", "((x))");
}
