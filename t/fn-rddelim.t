#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (rddelim '("") \")
!ERROR: missing-delimiter

> (rddelim '("\\") \")
!ERROR: missing-delimiter

> (rddelim '("\"") \")
nil

> (rddelim '("\\x\"") \")
"x"

