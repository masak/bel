#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (find atom '(a b c))
a

> (find atom '())
nil

> (find (fn (x) (id x 'b)) '(a b c))
b

> (find (fn (x) (id x 'q)) '(a b c))
nil

> (find no '(t t nil))
nil

> (find no '(t t))
nil

