#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set s '("hi"))
!IGNORE: result of assignment

> (charstil s (is \.))
"hi"

> s
(nil)

> (set s '("one two"))
!IGNORE: result of assignment

> (charstil s whitec)
"one"

> s
(" two")

> (charstil nil whitec)
!ERROR: ('unboundb bitc)

