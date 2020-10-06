#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (~~digit \0)
t

> (~~digit \7)
t

> (~~digit \9)
t

> (~~digit \0 i10)
t

> (~~digit \7 i10)
t

> (~~digit \9 i10)
t

> (digit \a)
nil

> (~~digit \a i16)
t

> (digit \b)
nil

> (~~digit \b i16)
t

> (digit \f)
nil

> (~~digit \f i16)
t

> (digit \g)
nil

> (digit \g i16)
nil

> (set i8 '(t t t t t t t t))
(t t t t t t t t)

> (~~digit \0 i8)
t

> (~~digit \7 i8)
t

> (digit \9 i8)
nil

