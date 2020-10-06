#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set L '((a . 1) (b . 2) (c . 3)))
!IGNORE: result of assignment

> (get 'b L)
(b . 2)

> (get 'd L)
nil

> (get 'x nil)
nil

> (set q '(b))
(b)

> (set L `(((a) . 1) (,q . two) ((c) . 3)))
!IGNORE: result of assignment

> (get '(b) L)
((b) . two)

> (get '(b) L id)
nil

> (get q L id)
((b) . two)

