#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output(
        "(accum a (map (cand odd a) '(1 2 3 4 5)))",
        "(1 3 5)"
    );
    is_bel_output(
        "(accum a (map [if (odd _) (a _)] '(1 2 3 4 5)))",
        "(1 3 5)"
    );
    is_bel_output(
        "(accum a (map [when (odd _) (a _) (a _)] '(1 2 3 4 5)))",
        "(1 1 3 3 5 5)"
    );
}
