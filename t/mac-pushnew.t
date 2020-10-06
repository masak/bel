#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x '(a b c))
(a b c)

> (pushnew 'a x)
(a b c)

> x
(a b c)

> (pushnew 'z x)
(z a b c)

> x
(z a b c)

> (set y '(a b c))
(a b c)

> (pushnew 'a y =)
(a b c)

> (pushnew 'z y =)
(z a b c)

> (pushnew 'z y =)
(z a b c)

> (set p '(a)
       L `(,p (b) (c)))
((a) (b) (c))

> (pushnew p L)
((a) (b) (c))

> (pushnew '(a) L id)
((a) (a) (b) (c))

> (set L `(,p (b) (c)))
!IGNORE: result of assignment, same as before

> (pushnew p L id)
((a) (b) (c))

