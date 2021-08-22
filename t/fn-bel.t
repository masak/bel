#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(apply idfn '(hi)))
hi

> (bel '(apply no '(t)))
nil

> (bel '(apply no '(nil)))
t

> (bel '(apply car '((a b))))
a

> (bel '(idfn 'hi))
hi

> (bel '(no t))
nil

> (bel '(no nil))
t

> (bel '(join 'a (ccc (lit clo nil (c) (c 'b)))))
(a . b)

> (bel '((lit mac (lit clo nil (x) x)) t))
t

> (bel '(after 1 2))
1

> (bel '(after 3 (car 'atom)))
!ERROR: car-on-atom

> (bel '(list 'a (ccc (lit clo nil (c) 'b))))
(a b)

> (bel '(dyn d 2 d))
2

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

> (bel '(quote a))
a

> (bel '(thread (car '(x . y))))
x

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

> (bel nil)
nil

> (bel t)
t

> (bel \x)
\x

> (do
    (bel '(pr 1 \lf))
    (pr 2 \lf))
1
2
(2 \lf)

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
!ERROR: mistype

> (bel '(nom nil))
"nil"

> (bel '(nom '(a)))
!ERROR: mistype

> (bel '(nom "a"))
!ERROR: mistype

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

!END: unlink "testfile";

> (bel '(a . b))
!ERROR: malformed

> (bel '(where x))
!ERROR: unbound

> (bel 'x)
!ERROR: (unboundb x)

> (bel '(where 'a))
!ERROR: unfindable

> (bel '(dyn \x 1 'hi))
!ERROR: cannot-bind

> (bel '((lit . x)))
!ERROR: bad-lit

> (bel '(t))
!ERROR: cannot-apply

> (bel '((lit clo (\x) nil t)))
!ERROR: bad-clo

> (bel '((lit clo nil \y t)))
!ERROR: bad-clo

> (bel '((lit cont (\x) nil)))
!ERROR: bad-cont

> (bel '((lit unp)))
!ERROR: unapplyable

> (bel '(car 'x 'y))
!ERROR: overargs

> (bel '((lit prim unk)))
!ERROR: unknown-prim

> (bel '(no 'a 'b))
!ERROR: overargs

> (pass t nil nil nil nil nil)
!ERROR: literal-parm

> (bel '(no))
!ERROR: underargs

> (bel '((lit clo nil ((x y)) nil) 'd))
!ERROR: atom-arg

> (bel '(join 'a (ccc (lit clo nil (c) (c)))))
!ERROR: wrong-no-args

> (bel '(join 'a (ccc (lit clo nil (c) (c 'x 'y)))))
!ERROR: wrong-no-args

> (bel 'vmark)
(nil)

> (bel '((lit clo nil (x) x) 'g))
g

> (bel '((lit clo nil (x) (where x)) 'g))
((x . g) d)

