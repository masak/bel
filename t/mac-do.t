#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (do 'a
      'b
      'c
      (list 'hello 'world))
(hello world)

> (do)
nil

> (do 'x
      'y)
y

