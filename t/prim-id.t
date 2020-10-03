#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (id 'a 'a)
t

> (id 'a 'b)
nil

> (id 'a \a)
nil

> (id \a \a)
t

> (id 't t)
t

> (id nil 'nil)
t

> (id id id)
t

> (id id 'id)
nil

> (id id nil)
nil

> (id nil)
t

> (id)
t

