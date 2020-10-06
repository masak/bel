#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (withfile f "testfile" 'out
    (set ff f)
    (stat f))
out

> (stat ff)
closed

!END: unlink("testfile");

