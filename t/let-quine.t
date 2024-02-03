#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (let let '`(let let ',let ,let) `(let let ',let ,let))
(let let (quote #1=(bquote (let let (quote (comma let)) (comma let)))) #1)

> (= (let let '`(let let ',let ,let) `(let let ',let ,let)) '(let let (quote #1=(bquote (let let (quote (comma let)) (comma let)))) #1))
t

