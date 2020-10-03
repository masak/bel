#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (list "hello be" . \l)
!ERROR: 'malformed

> (cons \e . \l)
!ERROR: 'malformed

> (\e . \l)
!ERROR: 'malformed

> ((lit clo nil nil))
nil

