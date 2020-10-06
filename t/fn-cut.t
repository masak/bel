#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (cut "foobar" 2 4)
"oob"

> (cut "foobar" 2 -1)
"ooba"

> (cut "foobar" 2)
"oobar"

> (cut "foobar")
"foobar"

