#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (some atom '(a b c))
(a b c)

> (some atom '())
nil

> (some is!b '(a b c))
(b c)

> (some is!q '(a b c))
nil

> (some no '(t t nil))
(nil)

> (some no '(t t))
nil

