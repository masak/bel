#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (match '(a b c) '(a b c))
t

> (match '(a b c) '(a D c))
nil

> (match '(a b c) '(a t c))
t

> (match '(a b c) '(t t t))
t

> (match '(a b c) '(t t))
nil

> (match '(a b c) '(t t t t))
nil

> (match '(a b c) `(a ,symbol c))
t

> (match '(a b c) `(,symbol ,symbol ,symbol))
t

> (match '(a b c) `(,symbol ,pair ,symbol))
nil

> (match '(a (b) c) `(,symbol ,pair ,symbol))
t

