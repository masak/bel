#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 64;

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
    is_bel_output("(bel '((lit clo nil (x) x) 'g))", "g");
    is_bel_output("(bel '((lit clo nil (x) (where x)) 'g))", "((x . g) d)");
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
    # the following two tests would probably work, but they are too slow.
    # even `(bel 'k!a)` is too slow right now. maybe later.
    #is_bel_output("(bel '(where ((lit tab (a . 1)) 'a)))", "((a . 1) 'd)");
    #is_bel_output("(bel '(where ((lit tab (a . 1)) 'b)))", "((b) 'd)");
}

# 'dyn' form
{
    is_bel_output("(bel '(dyn d 2 d))", "2");
}

# 'after' form
{
    is_bel_output("(bel '(after 1 2))", "1");
    is_bel_error(q[(bel '(after 3 (car 'atom)))], "car-on-atom");
}

# 'ccc' form
# see t/01-fn-bel-ccc.t

# 'thread' form
{
    is_bel_output("(bel '(thread (car '(x . y))))", "x");
}

# macro/applym
{
    is_bel_output("(bel '((lit mac (lit clo nil (x) x)) t))", "t");
}

# apply
{
    is_bel_output("(bel '(apply idfn '(hi)))", "hi");
    is_bel_output("(bel '(apply no '(t)))", "nil");
    is_bel_output("(bel '(apply no '(nil)))", "t");
    is_bel_output("(bel '(apply car '((a b))))", "a");
}

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

# continuation
{
    is_bel_output("(bel '(join 'a (ccc (lit clo nil (c) (c 'b)))))", "(a . b)");
}

END {
    unlink "testfile";
}