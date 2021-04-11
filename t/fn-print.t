#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (print 'foo)
    (prc \lf)
    nil)
foo
nil

> (do
    (print \T)
    (prc \lf)
    nil)
\T
nil

> (withfile f "testfile" 'out
    (print f)
    (prc \lf)
    nil)
<stream>
nil

> (do
    (print 1+i)
    (prc \lf)
    nil)
1+i
nil

> (let p (join)
    (set (car p) p)
    (set (cdr p) p)
    (print p)
    (prc \lf)
    nil)
#1=(#1 . #1)
nil

> (let p '(a b c)
    (set (cddr p) p)
    (print p)
    (prc \lf)
    nil)
#1=(a b . #1)
nil

> (let p '(a b)
    (set (cadr p) p)
    (print p)
    (prc \lf)
    nil)
#1=(a #1)
nil

> (do
    (print "foo")
    (prc \lf)
    nil)
"foo"
nil

> (do
    (print (list "abx" "dex"))
    (prc \lf)
    nil)
("abx" "dex")
nil

> (let p "x"
    (print (list (append "ab" p)
                 (append "de" p)))
    (prc \lf)
    nil)
((\a \b . #1=(\x)) (\d \e . #1))
nil

!END: unlink("testfile");

