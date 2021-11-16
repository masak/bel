#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bcfn!some atom '(a b c))
(a b c)

> (bcfn!some atom '())
nil

> (bcfn!some is!b '(a b c))
(b c)

> (bcfn!some is!q '(a b c))
nil

> (bcfn!some no '(t t nil))
(nil)

> (bcfn!some no '(t t))
nil

