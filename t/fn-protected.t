#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (set L1 (list (list smark 'foo)))
!IGNORE: result of assignment

> (protected L1)
nil

> (set L2 (list (list smark 'bind)))
!IGNORE: result of assignment

> (~~protected L2)
t

> (set L3 (list (list smark 'prot)))
!IGNORE: result of assignment

> (~~protected L3)
t

> (set L4 (list (list (join))))
!IGNORE: result of assignment

> (protected L4)
nil

