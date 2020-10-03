#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Language::Bel::Test::DSL;

__DATA__

> (source 'x)
nil

> (source (open "testfile" 'out))
t

> (source '(x))
nil

> (source (list ""))
t
> (source (list "abc"))
t
> (source (list \c))
nil

!END: unlink("testfile");

