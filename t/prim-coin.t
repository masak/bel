#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (~~mem (coin) '(t nil))
t

> (whilet _ (coin))
nil

> (til _ (coin) no)
nil

