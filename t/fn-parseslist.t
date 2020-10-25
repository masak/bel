#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parseslist '("hi" ".") i10)
!ERROR: final-intrasymbol

> (parseslist '("hello" "!") i10)
!ERROR: final-intrasymbol

> (parseslist '("one" "!." "two") i10)
!ERROR: double-intrasymbol

> (parseslist '("one" "!" "two:three") i10)
(one (quote (compose two three)))

> (parseslist '("one:two" "." "three") i10)
((compose one two) three)

> (parseslist '("one" "." "two" "." "three") i10)
(one two three)

> (parseslist '("one" "!" "two" "!" "three") i10)
(one (quote two) (quote three))

> (parseslist '("." "car") i10)
(upon car)

