#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (read '(""))
nil

> (read '("   "))
nil

> (read '("") 10 'eof)
eof

> (read '("   ") 10 'eof)
eof

> (read '("12") 10)
12

> (read '("12") 3)
5

> (read '("(foo bar baz)"))
(foo bar baz)

> (read '("\\"))
!ERROR: escape-without-char

> (read '("\\dufeqbef"))
!ERROR: unknown-named-char

> (read '("\\bel"))
\bel

> (read '("'foo"))
(quote foo)

> (read '("`foo"))
(bquote foo)

> (read '(",foo"))
(comma foo)

> (read '(",@foo"))
(comma-at foo)

> (def wrap (s c)
    `(,c ,@s ,c))
!IGNORE: result of definition

> (read (list (wrap "hi" \")))
"hi"

> (read (list (wrap "hi" \¦)))
hi

!TODO: currently the printer doesn't handle "special" symbols
> (read (list (wrap "hi there" \¦)))
¦hi there¦

