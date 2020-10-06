#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (breakc nil)
t

> (breakc \0)
nil

> (breakc \a)
nil

> (if (breakc \sp) t)
t

> (breakc \;)
t

> (breakc \3)
nil

> (if (breakc \() t)
t

> (if (breakc \[) t)
t

> (if (breakc \)) t)
t

> (if (breakc \]) t)
t

> (breakc \D)
nil

