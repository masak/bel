#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (len cbuf)
1

> (set s (open "testfile" 'out))
<stream>

> (len cbuf)
2

> (close s)
<stream>

> (len cbuf)
1

!END: unlink("testfile");

