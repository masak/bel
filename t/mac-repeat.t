#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set L1 nil)
nil

> (repeat 5
    (push 'hi L1))
nil

> L1
(hi hi hi hi hi)

> (set L2 nil)
nil

> (repeat 1
    (push 'hi L2))
nil

> L2
(hi)

> (set L3 nil)
nil

> (repeat 0
    (push 'hi L3))
nil

> L3
nil

> (set L4 nil)
nil

> (repeat -2
    (push 'hi L4))
nil

> L4
nil

