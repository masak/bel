#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

Bel Examples for Lisp Programmers   12 Oct 2019

When I hear about a new language, the first thing I want to see is
code examples. Programmers with significant experience in some dialect
of Lisp will probably be able to understand the following repl session.

> (cons 'a 'b '(c d e))
(a b c d e)

> (cons \h "ello")
"hello"

> (2 '(a b c))
b

> (set w '(a (b c) d (e f)))
(a (b c) d (e f))

> (find pair w)
(b c)

> (pop (find pair w))
b

> w
(a (c) d (e f))

> "TODO: (dedup:sort < \"abracadabra\") ==> \"abcdr\""
"TODO: (dedup:sort < \"abracadabra\") ==> \"abcdr\""

> (+ .05 19/20)
1

> (map (upon 2 3) (list + - * /))
(5 -1 6 2/3)

> (let x 'a
    (cons x 'b))
(a . b)

> (with (x 1 y 2)
    (+ x y))
3

> (let ((x y) . z) '((a b) c)
    (list x y z))
(a b (c))

> ((fn (x) (cons x 'b)) 'a)
(a . b)

> ((fn (x|symbol) (cons x 'b)) 'a)
(a . b)

> ((fn (x|int) (cons x 'b)) 'a)
!ERROR: mistype

(Erratum: the following has a misprint in `belexamples.txt`: `sym`
should be `symbol`. Using the corrected version for the test.)

> ((fn (f x|f) (cons x 'b)) symbol 'a)
(a . b)

> ((macro (v) `(set ,v 7)) x)
7

> x
7

> (let m (macro (x) (sym (append (nom x) "ness")))
    (set (m good) 10))
10

> goodness
10

> (apply or '(t nil))
t

> (best (of > len) '((a b) (a b c d) (a) (a b c)))
(a b c d)

> (!3 (part + 2))
5

> (to "testfile" (print 'hello))
nil

> (from "testfile" (read))
hello

> (set y (table))
(lit tab)

> (set y!a 1 y!b 2)
2

> (map y '(a b))
(1 2)

> (map ++:y '(a b))
(2 3)

> y!b
3

> (set z (array '(2 2) 0))
(lit arr (lit arr 0 0) (lit arr 0 0))

> (z 1 1)
0

> (for x 1 2
    (for y 1 2
      (set (z x y) (+ (* x 10) y))))
nil

> (z 1 1)
11

> (swap (z 1) (z 2))
(lit arr 11 12)

> (z 1 1)
21

!END: unlink("testfile");

