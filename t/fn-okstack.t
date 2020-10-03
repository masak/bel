#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (okstack nil)
t

> (okstack '(a))
nil

> (okstack '((b)))
nil

> (okstack '((c ((x . y)))))
t

> (okstack '((d ((x . y) (z . w)))))
t

> (okstack '((e nil) (f ((m . n)))))
t

