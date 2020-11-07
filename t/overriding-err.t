#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (def err args
    'overridden)
!IGNORE: result of definition

> (err 'something)
overridden

