#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (mac foo (x)
    ''b)
!IGNORE: output of definition

> (foo 'a)
b

> (mac bar (x)
    `(cons ,x ,x))
!IGNORE: output of definition

> (bar 'a)
(a . a)

