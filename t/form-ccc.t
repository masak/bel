#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (list 'a (ccc (fn (c) (set cont c) 'b)))
(a b)

> (cont 'z)
(a z)

> (cont 'w)
(a w)

There are spaces at the end of the `prn`'d lines.
Becuase that's how `prn` works according to spec.

> (do (ccc (fn (c)
             (set cont c)))
      (prn 1)
      3)
1 
3

> (after (cont 'ignore) (prn 2))
1 
2 
3

> (bind dvar "two"
    (after (cont 'ignore) (prn dvar)))
1 
"two" 
3

> (ccc)
!ERROR: bad-form

> (ccc a b)
!ERROR: bad-form

