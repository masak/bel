#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (lookup 'foo nil nil nil)
nil

`scope`, `globe`

> (lookup 'scope '((a . 1)) nil nil)
(scope (a . 1))

> (lookup 'globe nil nil '((b . 2)))
(globe (b . 2))

Global lookup (trumps `scope` and `globe`).

> (lookup 'foo nil nil '((foo . 0)))
(foo . 0)

> (lookup 'scope nil nil '((scope . 1)))
(scope . 1)

> (lookup 'globe nil nil '((globe . 2)))
(globe . 2)

Lexical lookup (trumps global lookup).

> (lookup 'foo '((foo . 0)) nil nil)
(foo . 0)

> (lookup 'foo '((foo . 1)) nil '((foo . 2)))
(foo . 1)

Dynamic lookup (trumps lexical lookup).

> (lookup 'foo nil (list (cons (list smark 'bind '(foo . 0)) nil)) nil)
(foo . 0)

> (lookup 'foo '((foo . 2)) (list (cons (list smark 'bind '(foo . 1)) nil)) nil)
(foo . 1)

> (lookup 'foo nil (list (cons (list smark 'bind '(foo . 1)) '((foo . 3)))) nil)
(foo . 1)

