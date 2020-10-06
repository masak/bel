#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

= Testing all possible ways to re-invoke `mev`.

== literal

> (bel nil)
nil

> (bel t)
t

> (bel \x)
\x

== variable

> (bel 'vmark)
(nil)

> (bel '((lit clo nil (x) x) 'g))
g

> (bel '((lit clo nil (x) (where x)) 'g))
((x . g) d)

== `quote` form

> (bel '(quote a))
a

== `if` form

> (bel '(if))
nil

> (bel '(if 'a))
a

> (bel '(if 'a 'b))
b

> (bel '(if 'a 'b 'c))
b

> (bel '(if nil 'b 'c))
c

== `where` form

> (bel '(where (car '(x . y))))
((x . y) a)

> (bel '(where (cdr '(z . w))))
((z . w) d)

The following two tests would probably work, but they are too slow.
Even `(bel 'k!a)` is too slow right now. Maybe later.

SKIP: > (bel '(where ((lit tab (a . 1)) 'a)))
SKIP: ((a . 1) 'd)

SKIP: > (bel '(where ((lit tab (a . 1)) 'b)))
SKIP: ((b) 'd)

== `dyn` form

> (bel '(dyn d 2 d))
2

== `after` form

> (bel '(after 1 2))
1

> (bel '(after 3 (car 'atom)))
!ERROR: car-on-atom

== `ccc` form
(see t/01-fn-bel-ccc.t)

== `thread` form

> (bel '(thread (car '(x . y))))
x

== macro/applym

> (bel '((lit mac (lit clo nil (x) x)) t))
t

== apply

> (bel '(apply idfn '(hi)))
hi

> (bel '(apply no '(t)))
nil

> (bel '(apply no '(nil)))
t

> (bel '(apply car '((a b))))
a

== primitive

> (bel '(car '(a . b)))
a

> (bel '(car '(a b)))
a

> (bel '(car nil))
nil

> (bel '(car))
nil

> (bel '(car 'atom))
!ERROR: car-on-atom

> (bel '(cdr '(a . b)))
b

> (bel '(cdr '(a b)))
(b)

> (bel '(cdr nil))
nil

> (bel '(cdr))
nil

> (bel '(cdr 'atom))
!ERROR: cdr-on-atom

> (bel '(id 'a 'a))
t

> (bel '(id 'a 'b))
nil

> (bel '(id 'a \a))
nil

> (bel '(id \a \a))
t

> (bel '(id 't t))
t

> (bel '(id nil 'nil))
t

> (bel '(id id id))
t

> (bel '(id id 'id))
nil

> (bel '(id id nil))
nil

> (bel '(id nil))
t

> (bel '(id))
t

> (bel '(join 'a 'b))
(a . b)

> (bel '(join 'a))
(a)

> (bel '(join))
(nil)

> (bel '(join nil 'b))
(nil . b)

> (bel '(id (join 'a 'b) (join 'a 'b)))
nil

> (bel '(nom 'a))
"a"

> (bel '(nom \a))
!ERROR: not-a-symbol

> (bel '(nom nil))
"nil"

> (bel '(nom '(a)))
!ERROR: not-a-symbol

> (bel '(nom "a"))
!ERROR: not-a-symbol

> (bel '(type 'a))
symbol

> (bel '(type \a))
char

> (bel '(type \bel))
char

> (bel '(type nil))
symbol

> (bel '(type '(a)))
pair

> (bel '(type (ops "testfile" 'out)))
stream

== closure

> (bel '(idfn 'hi))
hi

> (bel '(no t))
nil

> (bel '(no nil))
t

== continuation

> (bel '(join 'a (ccc (lit clo nil (c) (c 'b)))))
(a . b)

!END: unlink "testfile";

