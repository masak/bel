#!perl -w
# -T
use 5.006;
use strict;
use Language::Bel::Test::DSL;

__DATA__

> ((lit clo nil ((t xs pair)) xs) (join))
(nil)

> ((lit clo nil ((t xs pair)) xs) 'a)
!ERROR: 'mistype

> (def f1 ((t xs pair))
    xs)
!IGNORE: result of definition

> (f1 (join))
(nil)

> (f1 'a)
!ERROR: 'mistype

> (def f2 ((o (t (x . y) [caris _ 'a]) '(a . b)))
    x)
!IGNORE: result of definition

> (f2 '(b b))
!ERROR: 'mistype

> (f2)
a

> (def f3 (s (t n [~= _ nil]) d)
    (list s d n))
!IGNORE: result of definition

> (f3 '+ '(t t) '(t t t))
(+ (t t t) (t t))

> (f3 '+ nil '(t t t))
!ERROR: 'mistype

