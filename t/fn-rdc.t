#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set s '("hi"))
!IGNORE: result of assignment

> (rdc s)
\h

> (rdc s)
\i

> (rdc s)
nil

> (rdc nil)
!ERROR: ('unboundb bitc)

