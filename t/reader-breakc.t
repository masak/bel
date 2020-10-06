#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

Just checking that we properly roundtrip some characters via
the reader and the printer.

> \)
\)

> \]
\]

Note that there's a space (0x20) after the backslash.

> \     ; backslash space
\sp

