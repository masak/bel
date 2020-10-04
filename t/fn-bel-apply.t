#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (bel '(apply idfn '(hi)))
hi

> (bel '(apply no '(t)))
nil

> (bel '(apply no '(nil)))
t

> (bel '(apply car '((a b))))
a

