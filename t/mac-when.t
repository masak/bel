#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (when t
    "OH"
    " "
    "HAI")
"HAI"

> (when t
    "OH")
"OH"

> (when t)
nil

> (when nil
    "OH"
    " "
    "HAI")
nil

> (when nil
    "OH")
nil

> (when nil)
nil

