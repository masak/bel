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
(+ (t) (t t))

> (parsei "-2i" i10)
(- (t t) (t))

