#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set s '("    foo"))
!IGNORE: result of assignment

> (eatwhite s)
nil

> s
("foo")

> (set s (list (append "   ; comment" (list \lf) "hi")))
!IGNORE: result of assignment

> (eatwhite s)
nil

> s
("hi")

> (eatwhite nil)
nil

