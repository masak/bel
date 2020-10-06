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
((a b c) (b c) (c))

> (cells '(a nil c))
((a nil c) (nil c) (c))

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

