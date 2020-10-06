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

