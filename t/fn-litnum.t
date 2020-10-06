#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (litnum '(+ nil (t)))
0

> (litnum '(+ (t) (t)))
1

> (litnum '(+ nil (t)) '(+ (t) (t)))
+i

