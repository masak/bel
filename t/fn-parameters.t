#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parameters nil)
nil

> (parameters 'foo)
(foo)

> (parameters 'bar)
(bar)

> (parameters \c)
!ERROR: bad-parm

> (parameters '(t one))
(one)

> (parameters '(o two))
(two)

> (parameters '(one two three))
(one two three)

> (parameters '((((one)))))
(one)

> (parameters '((((one)) two) three))
(one two three)

> (parameters '((((one)) (o two)) three))
(one two three)

