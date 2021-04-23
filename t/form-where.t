#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set x 'hi)
hi

> (where x)
((x . hi) d)

> (xdr (car (where x)) 'bye)
!IGNORE: result of `xdr`

> x
bye

> (let x 'hi
    (where x))
((x . hi) d)

> (let x 'hi
    (xdr (car (where x)) 'bye)
    x)
bye

> (bind f6ac4d 'hi
    (where f6ac4d))
((f6ac4d . hi) d)

> (bind f6ac4d 'hi
    (xdr (car (where f6ac4d)) 'bye)
    f6ac4d)
bye

> (where (car '(a b c)))
((a b c) a)

> (where (cdr '(a b c)))
((a b c) d)

> (where (cadr '(a b c)))
((b c) a)

> (where (cddr '(a b c)))
((b c) d)

> (where (caddr '(a b c)))
((c) a)

> (where (find pair '(a b (c d) e)))
(((c d) e) a)

> (where (find pair '(a b e)))
!ERROR: unfindable

> (where (some pair '(a b (c d) e)))
((xs (c d) e) d)

> (where (some symbol '((a b) c d e)))
((xs c d e) d)

> (where (mem 'b '(a b c)))
((xs b c) d)

> (where (mem 'z '(a b c)))
!ERROR: unfindable

> (where (in 'b 'a 'b 'c))
((xs b c) d)

> (where (in 'z 'a 'b 'c))
!ERROR: unfindable

> (set kvs1 '((a . 1) (b . 2) (c . 3))
       kvs2 '(((a) . 1) ((b) . 2) ((c) . 3)))
!IGNORE: result of assignment

> (where (get 'b kvs1))
(((b . 2) (c . 3)) a)

> (where (get 'd kvs1))
!ERROR: unfindable

> (where (get '(b) kvs2))
((((b) . 2) ((c) . 3)) a)

> (where (get '(b) kvs2 id))
!ERROR: unfindable

> (set q '(b)
       kvs `(((a) . 1) (,q . two) ((c) . 3)))
!IGNORE: result of assignment

> (where (get q kvs id))
((((b) . two) ((c) . 3)) a)

> (where (idfn 'foo))
((x . foo) d)

> (where)
!ERROR: bad-form

> (where a b c)
!ERROR: bad-form

