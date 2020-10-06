#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (no nil)
t

> (no 'nil)
t

> (no '())
t

> (no t)
nil

> (no 'x)
nil

> (no \c)
nil

> (no '(nil))
nil

> (no '(a . b))
nil

> (no no)
nil

> (no (no no))
t

