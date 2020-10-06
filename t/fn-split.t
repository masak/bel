#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (split (is \a) "frantic")
("fr" "antic")

> (split no '(a b nil))
((a b) (nil))

> (split no '(a b c))
((a b c) nil)

> (split (is \i) "frantic" "quo")
("quofrant" "ic")

