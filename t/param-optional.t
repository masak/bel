#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> ((lit clo nil ((o x)) x) 'a)
a

> ((lit clo nil ((o x)) x))
nil

> ((lit clo nil ((o x 'b)) x) 'a)
a

> ((lit clo nil ((o x 'b)) x))
b

> ((lit clo nil ((o x) (o y)) (list x y)) 'a 'b)
(a b)

> ((lit clo nil ((o x) (o y)) (list x y)) 'a)
(a nil)

> ((lit clo nil ((o x) (o y)) (list x y)))
(nil nil)

> ((lit clo nil ((o x) (o y x)) (list x y)) 'c)
(c c)

> ((fn ((o x)) x) 'a)
a

> ((fn ((o x)) x))
nil

> ((fn ((o x 'b)) x) 'a)
a

> ((fn ((o x 'b)) x))
b

> ((fn ((o x) (o y)) (list x y)) 'a 'b)
(a b)

> ((fn ((o x) (o y)) (list x y)) 'a)
(a nil)

> ((fn ((o x) (o y)) (list x y)))
(nil nil)

> ((fn ((o x) (o y x)) (list x y)) 'c)
(c c)

> (let ((o x)) '(a) x)
a

> (let ((o x)) '() x)
nil

> (let ((o x 'b)) '(a) x)
a

> (let ((o x 'b)) '() x)
b

