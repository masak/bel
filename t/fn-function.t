#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (function (fn (x) x))
clo

> (function [_])
clo

> (function idfn)
clo

> (function car)
prim

> (function nil)
nil

> (function 'c)
nil

> (function '(a b c))
nil

> (function def)
nil

