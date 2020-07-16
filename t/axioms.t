#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 41;

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

{
    is_bel_output("(nom 'a)", q["a"]);
    is_bel_error("(nom \\a)", "not-a-symbol");
    is_bel_output("(nom nil)", q["nil"]);
    is_bel_error("(nom '(a))", "not-a-symbol");
    is_bel_error(q[(nom "a")], "not-a-symbol");
}

{
    is_bel_output("(~~mem (coin) '(t nil))", "t");
    is_bel_output("(whilet _ (coin))", "nil");
    is_bel_output("(til _ (coin) no)", "nil");
}

{
    is_bel_output(q[(ops "testfile" 'out)], "<stream>");
    is_bel_output(q[(type (ops "testfile" 'out))], "stream");
}
