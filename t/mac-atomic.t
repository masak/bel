#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> lock
!ERROR: (unboundb lock)

> (let f (fn () lock) (f))
!ERROR: (unboundb lock)

> (let f (fn () lock) (atomic (f)))
t

> (atomic 'hi)
hi

> (atomic lock)
t

> (atomic 'no 'but lock)
t

> (atomic (cons (atomic lock) lock))
(t . t)

`atomic` creates a dynamic binding of `lock`, which trumps any lexical
binding, whether inside or outside the `atomic` expression.

> (let lock 'lexical (atomic lock))
t

> (atomic (let lock 'lexical lock))
t

