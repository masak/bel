#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

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

