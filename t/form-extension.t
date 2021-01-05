#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (form hello ((e) a s r m)
    (mev s (cons (append "Hello " e "!") r) m))
!IGNORE: output of form definition

> (bel '(hello "world"))
"Hello world!"

