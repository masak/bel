#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> 'a:b:c
(compose a b c)

> '~n
(compose no n)

> 'a:~b:c
(compose a (compose no b) c)

> '~=
(compose no =)

> '~~z
(compose no (compose no z))

> '~<
(compose no <)

> '~
no

> '~~
(compose no no)

> 'for|2
(t for 2)

> 'a.b
(a b)

> 'a!b
(a (quote b))

> 'c|isa!cont
(t c (isa (quote cont)))

> '(id 2.x 3.x)
(id (2 x) (3 x))

> 'a!b.c
(a (quote b) c)

> '!a
(upon (quote a))

> (let x '(a . b) (map .x (list car cdr)))
(a b)

> 'x|~f:g!a
(t x ((compose (compose no f) g) (quote a)))

> inc.10
11

> (is.0 0)
t

