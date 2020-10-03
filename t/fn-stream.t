#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (stream 'x)
nil

> (stream nil)
nil

> (stream '(a))
nil

> (stream (join))
nil

> (stream \c)
nil

> (set f (ops "testfile" 'out))
<stream>

> (stream f)
t

!END: unlink("testfile");

