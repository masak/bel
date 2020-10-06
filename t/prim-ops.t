#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set f (ops "prim-ops-testfile" 'out))
<stream>

> (type f)
stream

> (cls f)
<stream>

> (set f (ops "prim-ops-testfile" 'in))
<stream>

> (type f)
stream

> (ops "rukyerw" 'in)
!ERROR: 'notexist

!END: unlink("prim-ops-testfile");

