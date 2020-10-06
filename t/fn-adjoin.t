#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (adjoin 'a '(a b c))
(a b c)

> (adjoin 'z '(a b c))
(z a b c)

> (adjoin 'a '(a b c) =)
(a b c)

> (adjoin 'z '(a b c) =)
(z a b c)

> (adjoin '(a) '((a) (b) (c)))
((a) (b) (c))

> (adjoin '(a) '((a) (b) (c)) id)
((a) (a) (b) (c))

> (let p '(a) (adjoin p `(,p (b) (c)) id))
((a) (b) (c))

