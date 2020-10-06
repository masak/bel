#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (to "alsieu" 'choo)
choo

!END: unlink("alsieu");

