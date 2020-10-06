#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (((combine and) atom no) nil)
t

> (((combine and) atom no) t)
nil

> (((combine and) atom) t)
t

> (((combine and) atom) (join))
nil

> (((combine and)) nil)
t

> (((combine or) pair no) nil)
t

> (((combine or) pair no) t)
nil

> (((combine or) pair no) '(x y))
t

> (((combine or) pair) (join))
t

> (((combine or)) nil)
nil

