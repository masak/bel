#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (keep [id _ \a] "abracadabra")
"aaaaa"

> (keep is!b '(a b c b a b))
(b b b)

> (keep is!b '(a c a))
nil

> (keep is!x nil)
nil

> (keep [] '(a b c b a b))
nil

