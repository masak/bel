#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (validi "+i" i10)
t

> (validi "+i" i0)
t

> (validi "-i" i10)
t

> (validi "+0i" i10)
t

> (validi "+0" i10)
nil

> (validi "+0j" i10)
nil

> (validi "-fi" i10)
nil

> (validi "-fi" i16)
t

> (validi "+1.0i" i10)
t

> (validi "-.1fi" i10)
nil

> (validi "-.1fi" i16)
t

> (validi "+.i" i10)
nil

> (validi "-1/2.i" i10)
t

> (validi "+1/.2i" i10)
t

> (validi "-1/.i" i10)
nil

> (validi "-1.0/2.0i" i10)
t

> -1.0/2.0i
-1/2i

