#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (type (fu (s r m) s))
pair

> (= (fu (s r m) s) `((,smark fut (lit clo nil (s r m) s)) nil))
t

> (= (fu (s r m) r) `((,smark fut (lit clo nil (s r m) r)) nil))
t

> (id (car:car (fu (s r m) (cdr s))) smark)
t

