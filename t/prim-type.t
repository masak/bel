#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (type 'a)
symbol

> (type \a)
char

> (type \bel)
char

> (type nil)
symbol

> (type '(a))
pair

> (set f (ops "testfile" 'out))
<stream>

> (type f)
stream

!END: unlink("testfile");

