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
    (dyn err (fn (msg) (set n msg))
      (car 'nonpair))
    n)
car-on-atom

But you cannot override `err` lexically.

> (let n nil
    (let err (fn (msg) (set n msg))
      (car 'nonpair))
    n)
nil

> (let n nil
    (dyn err (fn (msg) (set n msg))
      (cdr 'nonpair))
    n)
cdr-on-atom

> (let n nil
    (dyn err (fn (msg) (set n msg))
      (cls 'nonstream))
    n)
mistype

> (let n nil
    (dyn err (fn (msg) (set n msg))
      (nom "nonsymbol"))
    n)
mistype

> (let n nil
    (dyn err (fn (msg) (set n msg))
      (ops 'nonstring 'out))
    n)
mistype

> (let n nil
    (dyn err (fn (msg) (set n msg))
      (ops "some-file" "nonsymbol"))
    n)
mistype

> (let n nil
    (dyn err (fn (msg) (set n msg))
      (ops "some-file" 'neither-in-or-out))
    n)
mistype

