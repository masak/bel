#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set s (open "README.md" 'in))
<stream>

> (mac mmm () s)
!IGNORE: result of macro evaluation

> (mmm)
<stream>

