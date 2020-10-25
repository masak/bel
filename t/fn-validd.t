#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (validd "" i10)
nil

> (validd "0" i10)
t

> (validd "1" i10)
t

> (validd "9" i10)
t

> (validd "f" i10)
nil

> (validd "f" i16)
t

> (validd "10" i10)
t

> (validd "1.0" i10)
t

> (validd "1..0" i10)
nil

> (validd "10." i10)
t

> (validd ".10" i10)
t

> (validd ".1f" i10)
nil

> (validd ".1f" i16)
t

> (validd "." i10)
nil

> (validd "1.0." i10)
nil

> (validd ".1.0" i10)
nil

> (validd ".10." i10)
nil

