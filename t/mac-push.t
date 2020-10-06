#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

Push is destructive, in the sense that it actually changes its second
argument.

> (let L '(b c)
    (push 'a L)
    L)
(a b c)

You can push to the `cdr` of a list!

> (let L '(b c)
    (push 'a (cdr L))
    L)
(b a c)

> (let L nil
    (push 'a L)
    L)
(a)

> (bind L '(h i)
    (push 'g L)
    L)
(g h i)

> (def f (v) (push 'g L))
!IGNORE: result of definition

> (bind L '(h i)
    (f 'g)
    L)
(g h i)

