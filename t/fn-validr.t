#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (validr "" i10)
nil

> (validr "0" i10)
t

> (validr "1" i10)
t

> (validr "9" i10)
t

> (validr "f" i10)
nil

> (validr "f" i16)
t

> (validr "10" i10)
t

> (validr "1.0" i10)
t

> (validr "1..0" i10)
nil

> (validr "10." i10)
t

> (validr ".10" i10)
t

> (validr ".1f" i10)
nil

> (validr ".1f" i16)
t

> (validr "." i10)
nil

> (validr "1.0." i10)
nil

> (validr ".1.0" i10)
nil

> (validr ".10." i10)
nil

> (validr "1/2" i10)
t

> (validr "1/" i10)
nil

> (validr "/2" i10)
nil

> (validr "1/2/3" i10)
nil

> (validr "1./2" i10)
t

> (validr "1/2." i10)
t

> (validr "1/.2" i10)
t

> (validr "1/." i10)
nil

> (validr "1.0/2.0" i10)
t

