#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> smark
(nil)

> (id vmark smark)
nil

> (inwhere nil)
nil

> (inwhere `(((,smark))))
nil

> (inwhere `(((,smark nope))))
nil

> (inwhere `(((,smark loc t))))
(t)

> (inwhere `(((,smark loc nil))))
(nil)

> (inwhere `(((,smark loc foo))))
(foo)

> (inwhere `(((,smark loc))))
nil

