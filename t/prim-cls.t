#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set f (ops "testfile" 'out))
<stream>

> (cls f)
<stream>

> (stat f)
closed

> (cls f)
!ERROR: 'already-closed

> (cls 'not-a-stream)
!ERROR: mistype

!END: unlink("testfile");

