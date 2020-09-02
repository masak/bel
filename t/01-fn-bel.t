#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 53;

## Testing all possible ways to re-invoke `mev

# literal
{
    is_bel_output("(bel nil)", "nil");
    is_bel_output("(bel t)", "t");
    is_bel_output("(bel \\x)", "\\x");
}

# variable
{
    is_bel_output("(bel 'vmark)", "(nil)");
    # TODO: lexical variable
    # TODO: dynamic variable
    # TODO: unbound variable
    # TODO: inwhere case
}

# 'quote' form
{
    is_bel_output("(bel '(quote a))", "a");
}

# 'if' form
{
    is_bel_output("(bel '(if))", "nil");
    is_bel_output("(bel '(if 'a))", "a");
    is_bel_output("(bel '(if 'a 'b))", "b");
    is_bel_output("(bel '(if 'a 'b 'c))", "b");
    is_bel_output("(bel '(if nil 'b 'c))", "c");
}

# 'where' form
{
    is_bel_output("(bel '(where (car '(x . y))))", "((x . y) a)");
    is_bel_output("(bel '(where (cdr '(z . w))))", "((z . w) d)");
}

# TODO: 'dyn' form
# TODO: 'after' form
# TODO: 'ccc' form
# TODO: 'thread' form

# macro/applym
{
    is_bel_output("(bel '((lit mac (lit clo nil (x) x)) t))", "t");
}

# TODO: apply
# TODO: improper lit
# TODO: applyf not a lit
# TODO: locfn

# primitive
{
    is_bel_output("(bel '(car '(a . b)))", "a");
    is_bel_output("(bel '(car '(a b)))", "a");
    is_bel_output("(bel '(car nil))", "nil");
    is_bel_output("(bel '(car))", "nil");
    is_bel_error("(bel '(car 'atom))", "car-on-atom");
    is_bel_output("(bel '(cdr '(a . b)))", "b");
    is_bel_output("(bel '(cdr '(a b)))", "(b)");
    is_bel_output("(bel '(cdr nil))", "nil");
    is_bel_output("(bel '(cdr))", "nil");
    is_bel_error("(bel '(cdr 'atom))", "cdr-on-atom");
    #is_bel_output("(bel '(~~mem (coin) '(t nil)))", "t");
    #is_bel_output("(bel '(whilet _ (coin)))", "nil");
    #is_bel_output("(bel '(til _ (coin) no))", "nil");
    is_bel_output("(bel '(id 'a 'a))", "t");
    is_bel_output("(bel '(id 'a 'b))", "nil");
    is_bel_output("(bel '(id 'a \\a))", "nil");
    is_bel_output("(bel '(id \\a \\a))", "t");
    is_bel_output("(bel '(id 't t))", "t");
    is_bel_output("(bel '(id nil 'nil))", "t");
    is_bel_output("(bel '(id id id))", "t");
    is_bel_output("(bel '(id id 'id))", "nil");
    is_bel_output("(bel '(id id nil))", "nil");
    is_bel_output("(bel '(id nil))", "t");
    is_bel_output("(bel '(id))", "t");
    is_bel_output("(bel '(join 'a 'b))", "(a . b)");
    is_bel_output("(bel '(join 'a))", "(a)");
    is_bel_output("(bel '(join))", "(nil)");
    is_bel_output("(bel '(join nil 'b))", "(nil . b)");
    is_bel_output("(bel '(id (join 'a 'b) (join 'a 'b)))", "nil");
    is_bel_output("(bel '(nom 'a))", q["a"]);
    is_bel_error("(bel '(nom \\a))", "not-a-symbol");
    is_bel_output("(bel '(nom nil))", q["nil"]);
    is_bel_error("(bel '(nom '(a)))", "not-a-symbol");
    is_bel_error(q[(bel '(nom "a")], "not-a-symbol");
    is_bel_output("(bel '(type 'a))", "symbol");
    is_bel_output("(bel '(type \\a))", "char");
    is_bel_output("(bel '(type \\bel))", "char");
    is_bel_output("(bel '(type nil))", "symbol");
    is_bel_output("(bel '(type '(a)))", "pair");
    is_bel_output(q[(bel '(type (ops "testfile" 'out)))], "stream");
}

# closure
{
    is_bel_output("(bel '(idfn 'hi))", "hi");
    is_bel_output("(bel '(no t))", "nil");
    is_bel_output("(bel '(no nil))", "t");
}

END {
    unlink "testfile";
}
