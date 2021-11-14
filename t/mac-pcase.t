#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (pcase nil
    no   'one
    char 'two
         'three)
one

> (pcase \x
    no   'one
    char 'two
         'three)
two

> (pcase (join)
    no   'one
    char 'two
         'three)
three

> (pcase "hi"
    string   'four
    function 'five)
four

> (pcase idfn
    string   'four
    function 'five)
five

> (pcase car
    string   'four
    function 'five)
five

> (pcase 'symbol
    string   'four
    function 'five)
nil

The following few tests assert that if the pcase doesn't contain any cases --
either nothing or at most the default -- the expression isn't even evaluated.

> (let E nil
    (pcase (do (zap snoc E 'evaluated)
              'foo)
      symbol (zap snoc E 'matched))
    E)
(evaluated matched)

> (let E nil
    (pcase (do (zap snoc E 'evaluated)
              'foo)
      'boo))
boo

> (let E nil
    (pcase (do (zap snoc E 'evaluated)
              'foo)
      'boo)
    E)
nil

> (let E nil
    (pcase (do (zap snoc E 'evaluated)
              'foo)))
nil

> (let E nil
    (pcase (do (zap snoc E 'evaluated)
              'foo))
    E)
nil

