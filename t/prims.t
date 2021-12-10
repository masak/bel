#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (type prims)
pair

> (all pair prims)
t

> (if (mem 'coin (1 (rev prims))) t)
t

> (~~mem 'car (2 (rev prims)))
t

> (~~mem 'cdr (2 (rev prims)))
t

> (~~mem 'type (2 (rev prims)))
t

> (~~mem 'sym (2 (rev prims)))
t

> (~~mem 'nom (2 (rev prims)))
t

> (~~mem 'rdb (2 (rev prims)))
t

> (~~mem 'cls (2 (rev prims)))
t

> (~~mem 'stat (2 (rev prims)))
t

> (~~mem 'sys (2 (rev prims)))
t

> (~~mem 'id (3 (rev prims)))
t

> (~~mem 'join (3 (rev prims)))
t

> (~~mem 'xar (3 (rev prims)))
t

> (~~mem 'xdr (3 (rev prims)))
t

> (~~mem 'wrb (3 (rev prims)))
t

> (~~mem 'ops (3 (rev prims)))
t

