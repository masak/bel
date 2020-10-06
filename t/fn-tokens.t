#!perl -T
use 5.006;
use strict;
use warnings;
use Language::Bel::Test::DSL;

__DATA__

> (tokens "the age of the essay")
("the" "age" "of" "the" "essay")

> (tokens "A|B|C")
("A|B|C")

> (tokens "A|B|C" \|)
("A" "B" "C")

> (tokens "A.B:C.D!E:F"
          (cor (is \.) (is \:)))
("A" "B" "C" "D!E" "F")

