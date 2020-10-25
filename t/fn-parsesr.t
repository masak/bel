#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (parsesr "+1/2" i10)
(+ (t) (t t))

> (parsesr "1/2" i10)
(+ (t) (t t))

> (parsesr "-1/2" i10)
(- (t) (t t))

> (parsesr "-1.0/3.0" i10)
(- (t) (t t t))

