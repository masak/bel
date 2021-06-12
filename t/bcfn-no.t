#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!no nil)
t

> (bcfn!no 'nil)
t

> (bcfn!no '())
t

> (bcfn!no t)
nil

> (bcfn!no 'x)
nil

> (bcfn!no \c)
nil

> (bcfn!no '(nil))
nil

> (bcfn!no '(a . b))
nil

> (bcfn!no no)
nil

> (bcfn!no bcfn!no)
nil

> (bcfn!no (bcfn!no bcfn!no))
t

