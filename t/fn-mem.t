#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (mem 'b '(a b c))
(b c)

> (mem 'e '(a b c))
nil

> (mem \a "foobar")
"ar"

> (mem '(x) '((a) b x))
nil

> (mem '(x) '((a) b (x)))
((x))

> (mem '(x) '((a) b (x)) id)
nil

> (let q '(x) (mem q `((a) b ,q)))
((x))

