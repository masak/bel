#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parsesr "+1/2" i10)
(+ #1=(t) (t . #1))

> (parsesr "1/2" i10)
(+ #1=(t) (t . #1))

> (parsesr "-1/2" i10)
(- #1=(t) (t . #1))

> (parsesr "-1.0/3.0" i10)
(- #1=(t) (t t . #1))

