#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (signc nil)
nil

> (signc \0)
nil

> (signc \a)
nil

> (~~signc \+)
t

> (~~signc \-)
t

> (signc \;)
nil

> (signc \3)
nil

> (signc \D)
nil

