#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (2 '(a b c))
b

> (let arr (array '(3) 0)
    (arr 2))
0

> (let arr (array '(3) 'x)
    (arr 3))
x

> (let arr (array '(2 2) 0)
    (arr 2 1))
0

> (let arr (array '(2 2) 'x)
    (arr 1 2))
x

> (set tab (table '((a . 1)
                    (b . 2))))
!IGNORE: result of assignment

> (tab 'a)
1

> (tab 'b)
2

> (tab 'c)
nil

> (tab 'c 3)
3

> (let tab (table '((x . 1)
                    (x . 2)))
    (tab 'x))
1

> (push `(num . ,(fn (f args) ''haha))
        virfns)
!IGNORE: result of `push`

> (2 '(a b c))
haha

> (pop virfns)
!IGNORE: result of `pop`

> (2 '(a b c))
b

