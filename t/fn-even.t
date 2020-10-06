#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (even 0)
t

> (even -1)
nil

> (even 1/2)
nil

> (even 4/2)
t

> (even 3)
nil

> (even 4)
t

Arguably, it is a bug that `even` produces an error on non-numeric
values. But it is according to spec -- so if it's a bug, it's a bug
in the spec.

> (even \x)
!ERROR: cdr-on-atom

> (even \0)
!ERROR: cdr-on-atom

