#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (isa!clo (fn (x) x))
t

> (isa!clo [_])
t

> (isa!clo idfn)
t

> (isa!prim car)
t

> (isa!clo nil)
nil

> (isa!clo 'c)
nil

> (isa!clo '(a b c))
nil

> (isa!mac def)
t

