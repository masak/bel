#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (prc \c)
    (prc \lf)
    nil)
c
nil

> (do
    (prc \B)
    (prc \lf)
    nil)
B
nil

> (withfile f "temp3827" 'out
    (each c "abc"
      (prc c f)))
!IGNORE: result of each

> (withfile f "temp3827" 'in
    (nof 4 (rdc f)))
(\a \b \c nil)

> (set s '("ab"))
!IGNORE: result of assignment

> (prc \c s)
\c

> s
("abc")

!END: unlink("temp3827");
