#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (< 2 4)
t

> (< 5 3)
nil

> "TODO (< \\a \\c) ==> t"
"TODO (< \\a \\c) ==> t"

> "TODO (< \\d \\b) ==> nil"
"TODO (< \\d \\b) ==> nil"

> "TODO (< \"aa\" \"ac\") ==> t"
"TODO (< \"aa\" \"ac\") ==> t"

> "TODO (< \"bc\" \"ab\") ==> nil"
"TODO (< \"bc\" \"ab\") ==> nil"

> "TODO (< 'aa 'ac) ==> t"
"TODO (< 'aa 'ac) ==> t"

> "TODO (< 'bc 'ab) ==> nil"
"TODO (< 'bc 'ab) ==> nil"

