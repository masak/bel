#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x '(a b c)
       y '())
nil

> (whilet e (pop x)
    (push e y))
nil

> y
(c b a)

> (set x '()
       y '())
nil

> (whilet e (pop x)
    (push e y))
nil

> y
nil

> (mac moo ()
    (letu vx `(whilet ,vx (pop L)
                (push ,vx K))))
!IGNORE: result of definition

> (set L '(a b c d)
       K '())
nil

> (moo)
nil

> K
(d c b a)

