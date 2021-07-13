#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!append '(a b c) '(d e f))
(a b c d e f)

> (bcfn!append '(a)
               nil
               '(b c)
               '(d e f))
(a b c d e f)

> (bcfn!append)
nil

> (let p '(b)
    (id (cdr (bcfn!append '(a) p)) p))
t

> (let p '(b)
    (id (cdr (bcfn!append '(a) p nil)) p))
nil

