#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rdex '(""))
(nil nil)

> (rdex '("   "))
(nil nil)

> (rdex '("") i10 'eof)
(eof nil)

> (rdex '("   ") i10 'eof)
(eof nil)

> (rdex '("(foo bar baz)"))
((foo bar baz) nil)

