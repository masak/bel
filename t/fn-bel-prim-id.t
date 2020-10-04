#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(id 'a 'a))
t

> (bel '(id 'a 'b))
nil

> (bel '(id 'a \a))
nil

> (bel '(id \a \a))
t

> (bel '(id 't t))
t

> (bel '(id nil 'nil))
t

> (bel '(id id id))
t

> (bel '(id id 'id))
nil

> (bel '(id id nil))
nil

> (bel '(id nil))
t

> (bel '(id))
t

