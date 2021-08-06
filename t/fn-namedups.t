#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (len (namedups '(a)))
0

> (len (namedups '(a b c)))
0

> (let L '(a)
    (xar L L)
    (namedups L))
((#1=(#1) . 1))

> (let L '(a)
    (xar L L)
    L)
#1=(#1)

> (let L '(a)
    (xdr L L)
    (namedups L))
((#1=(a . #1) . 1))

> (let L '(a)
    (xdr L L)
    L)
#1=(a . #1)

