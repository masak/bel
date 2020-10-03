#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (snap nil nil)
(nil nil)

> (snap nil '(a b c))
(nil (a b c))

> (snap '(x) '(a b c))
((a) (b c))

> (snap '(x y z w) '(a b c))
((a b c nil) nil)

> (snap '(x) '(a b c) '(d e))
((d e a) (b c))

