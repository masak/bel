#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (prnice 'foo)
    (prc \lf)
    nil)
foo
nil

> (do
    (prnice \T)
    (prc \lf)
    nil)
T
nil

> (withfile f "testfile" 'out
    (prnice f)
    (prc \lf)
    nil)
<stream>
nil

> (do
    (prnice 1+i)
    (prc \lf)
    nil)
1+i
nil

> (do
    (prnice "foo")
    (prc \lf)
    nil)
foo
nil

> (do
    (prnice (list "abx" "dex"))
    (prc \lf)
    nil)
("abx" "dex")
nil

!END: unlink("testfile");

