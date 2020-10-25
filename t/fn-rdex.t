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

> (rdex '("\\"))
!ERROR: escape-without-char

> (rdex '("\\dufeqbef"))
!ERROR: unknown-named-char

> (rdex '("\\bel"))
(\bel nil)

> (rdex '("'foo"))
((quote foo) nil)

> (rdex '("`foo"))
((bquote foo) nil)

> (rdex '(",foo"))
((comma foo) nil)

> (rdex '(",@foo"))
((comma-at foo) nil)

> (def wrap (s c)
    `(,c ,@s ,c))
!IGNORE: result of definition

> (rdex (list (wrap "hi" \")))
("hi" nil)

> (rdex (list (wrap "hi" \¦)))
(hi nil)

!TODO: currently the printer doesn't handle "special" symbols
> (rdex (list (wrap "hi there" \¦)))
(¦hi there¦ nil)

