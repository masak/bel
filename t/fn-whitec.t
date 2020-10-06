#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (~~whitec \sp)
t

> (~~whitec \lf)
t

> (~~whitec \tab)
t

> (~~whitec \cr)
t

> (~~whitec \a)
nil

> (~~whitec \b)
nil

> (~~whitec \x)
nil

> (~~whitec \1)
nil

