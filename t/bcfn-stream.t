#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!stream 'x)
nil

> (bcfn!stream nil)
nil

> (bcfn!stream '(a))
nil

> (bcfn!stream (join))
nil

> (bcfn!stream \c)
nil

> (set f (ops "testfile" 'out))
<stream>

> (bcfn!stream f)
t

!END: unlink("testfile");

