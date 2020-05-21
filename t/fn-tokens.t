#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output(qq[(tokens "the age of the essay")], qq[("the" "age" "of" "the" "essay")]);
    is_bel_output(qq[(tokens "A|B|C")], qq[("A|B|C")]);
    is_bel_output(qq[(tokens "A|B|C" \\|)], qq[("A" "B" "C")]);
    is_bel_output(qq[(tokens "A.B:C.D!E:F" (cor (is \\.) (is \\:)))], qq[("A" "B" "C" "D!E" "F")]);
}
