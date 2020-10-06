#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (hug '(a b c d))
((a b) (c d))

> (hug '(a b c d e))
((a b) (c d) (e))

> (hug '(a b c d) cons)
((a . b) (c . d))

> (hug '(a b c d e) cons)
((a . b) (c . d) e)

