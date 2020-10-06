#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (intrac nil)
nil

> (intrac \0)
nil

> (intrac \a)
nil

> (~~intrac \.)
t

> (~~intrac \!)
t

> (intrac \+)
nil

> (intrac \-)
nil

> (intrac \D)
nil

