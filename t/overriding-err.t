#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (def err args
    'overridden)
!IGNORE: result of definition

> (err 'something)
overridden

> (let n nil
    (dyn err (fn args (set n t))
      (car 'nonpair))
    n)
t

But you cannot override `err` lexically.

> (let n nil
    (let err (fn args (set n t))
      (car 'nonpair))
    n)
nil

> (let n nil
    (dyn err (fn args (set n t))
      (cdr 'nonpair))
    n)
t

> (let n nil
    (dyn err (fn args (set n t))
      (cls 'nonstream))
    n)
t

