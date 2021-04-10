#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do
    (presc "B\\o\"b" \" outs)
    (prc \lf)
    nil)
B\\o\"b
nil

> (withfile f "temp2923" 'out
    (presc "1\\2\"3" \" f))
!IGNORE: return value of presc

> (withfile f "temp2923" 'in
    (nof 8 (rdc f)))
(\1 \\ \\ \2 \\ \" \3 nil)

> (set s '("?"))
!IGNORE: result of assignment

> (presc "a!b" \! s)
!IGNORE: return value of presc

> s
("?a\\!b")

!END: unlink("temp2923");

