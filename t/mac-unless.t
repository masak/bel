#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (unless t
    "OH"
    " "
    "HAI")
nil

> (unless t
    "OH")
nil

> (unless t)
nil

> (unless nil
    "OH"
    " "
    "HAI")
"HAI"

> (unless nil
    "OH")
"OH"

> (unless nil)
nil

