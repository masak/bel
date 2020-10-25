#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parsed "1" i10)
((t) (t))

> (parsed "1." i10)
((t) (t))

> (parsed "1.0" i10)
((t t t t t t t t t t) (t t t t t t t t t t))

> (parsed "1.2" i10)
((t t t t t t t t t t t t) (t t t t t t t t t t))

> (parsed ".1" i10)
((t) (t t t t t t t t t t))

