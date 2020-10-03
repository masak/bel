#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (record (enq \a outs) (enq \b outs) (enq \c outs))
"abc"

> (record (map [enq _ outs] '(\x \y \z)))
"xyz"

> (record)
nil

!TODO: The `pr` function does not yet respect `outs`
> (record (pr (append "hello" '(\lf))))
"hello\lf"

