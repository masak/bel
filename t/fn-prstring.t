#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (prstring "Bob" outs nil nil)
    (prc \lf)
    nil)
"Bob"
nil

> (withfile f "temp8237" 'out
    (prstring "123" f nil nil))
nil

> (withfile f "temp8237" 'in
    (nof 6 (rdc f)))
(\" \1 \2 \3 \" nil)

> (set s '("!"))
!IGNORE: result of assignment

> (prstring "hi" s nil nil)
nil

> s
("!\"hi\"")

!END: unlink("temp8237");
