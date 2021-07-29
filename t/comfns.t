#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (< 2 4)
t

> (< 5 3)
nil

> (< \a \c)
t

> (< \d \b)
nil

> (< "aa" "ac")
t

> (< "bc" "ab")
nil

> (< 'aa 'ac)
t

> (< 'bc 'ab)
nil

