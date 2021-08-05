#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (cells nil)
nil

> (cells \c)
nil

> (cells '())
nil

> (cells '(nil))
((nil))

> (cells '(a b c))
((a . #1=(b . #2=(c))) #1 #2)

> (cells '(a nil c))
((a . #1=(nil . #2=(c))) #1 #2)

> (let L '(a)
    (xar L L)
    (list (len (cells L))
          (len (dups (cells L) id))))
(2 1)

> (let L '(a)
    (xdr L L)
    (list (len (cells L))
          (len (dups (cells L) id))))
(2 1)

