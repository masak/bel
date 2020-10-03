#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> "Bel"
"Bel"

> ""
nil

> (cons \s "tring")
"string"

> (cons \s \t \r \i \n \g nil)
"string"

> (cdr "max")
"ax"

> (cdr "\\")
nil

> (car "\"")
\"

> "\\"
"\\"

> "\""
"\""

