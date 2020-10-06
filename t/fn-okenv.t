#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (okenv nil)
t

> (okenv '(a . b))
nil

> (okenv '(a))
nil

> (okenv '((a . b)))
t

> (okenv '((a . b) (c . d)))
t

> (okenv '((a . b) nil (c . d)))
nil

> (okenv '((a . b) (nil) (c . d)))
t

