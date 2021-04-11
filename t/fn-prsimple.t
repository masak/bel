#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (prsimple 'foo outs)
    (prc \lf)
    nil)
foo
nil

> (do
    (prsimple \T outs)
    (prc \lf)
    nil)
\T
nil

> (withfile f "testfile" 'out
    (prsimple f outs)
    (prc \lf)
    nil)
<stream>
nil

> (do
    (prsimple 1+i outs)
    (prc \lf)
    nil)
1+i
nil

!END: unlink("testfile");

