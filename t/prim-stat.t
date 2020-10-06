#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set f (ops "testfile" 'out))
<stream>

> (stat f)
out

> (cls f)
<stream>

> (stat f)
closed

!END: unlink("testfile");

