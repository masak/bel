#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((compose no atom) 'x)
nil

> ((compose no atom) nil)
nil

> ((compose no atom) '(a x))
t

> ((compose cdr cdr cdr) '(a b c d))
(d)

> ((compose) '(a b c d))
(a b c d)

