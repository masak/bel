#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((cand atom no) nil)
t

> ((cand atom no) t)
nil

> ((cand atom) t)
t

> ((cand atom) (join))
nil

> ((cand) nil)
t

