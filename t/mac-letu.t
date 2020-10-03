#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (letu va
    (variable va))
t

> (letu va
    ([= _ (uvar)] va))
t

> (letu va
    (id vmark (car va)))
t

> (letu (vb vc)
    (and (variable vb)
         (variable vc)))
t

> (letu (vb vc)
    (and ([= _ (uvar)] vb)
         ([= _ (uvar)] vc)))
t

> (letu (vb vc)
    (and (id vmark (car vb))
         (id vmark (car vc))))
t

