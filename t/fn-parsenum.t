#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parsenum "+i" i10)
+i

> (parsenum "-i" i10)
-i

> (parsenum "2" i10)
2

> (parsenum "+2" i10)
2

> (parsenum "-2" i10)
-2

> (parsenum "2+3i" i10)
2+3i

> (parsenum "+2+3i" i10)
2+3i

> (parsenum "-2+3i" i10)
-2+3i

