#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (function (upon '(a b c)))
clo

> ((upon '(a b c)) cdr)
(b c)

> (map (upon '(a b c)) (list car cadr cdr))
(a b (b c))

