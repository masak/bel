#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parsei "+i" i10)
(+ (t) (t))

> (parsei "-i" i10)
(- (t) (t))

> (parsei "+1/2i" i10)
(+ #1=(t) (t . #1))

> (parsei "-2i" i10)
(- (t . #1=(t)) #1)

