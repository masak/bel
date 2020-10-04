#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(idfn 'hi))
hi

> (bel '(no t))
nil

> (bel '(no nil))
t

