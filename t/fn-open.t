#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (len cbuf)
1

> (set f (open "fn-open-testfile" 'out))
<stream>

> (type f)
stream

> (len cbuf)
2

> (close f)
<stream>

> (len cbuf)
1

> (type (open "fn-open-testfile" 'in))
stream

> (len cbuf)
2

!END: unlink("fn-open-testfile");

