#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

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

