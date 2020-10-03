#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set q (newq))
(nil)

> (enq 'a q)
((a))

> (enq 'b q)
((a b))

> (enq 'c q)
((a b c))

