#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (with (r (numr 2+3i)
         i (numi 2+3i))
    (prnum r i outs)
    (prc \lf)
    nil)
2+3i
nil

> (with (r (numr -1-2i)
         i (numi -1-2i))
    (prnum r i outs)
    (prc \lf)
    nil)
-1-2i
nil

