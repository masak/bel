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

!TODO: `chars` not implemented yet
> (< \a \c)
t

!TODO: `chars` not implemented yet
> (< \d \b)
nil

!TODO: `chars` not implemented yet
> (< "aa" "ac")
t

!TODO: `chars` not implemented yet
> (< "bc" "ab")
nil

!TODO: `chars` not implemented yet
> (< 'aa 'ac)
t

!TODO: `chars` not implemented yet
> (< 'bc 'ab)
nil

