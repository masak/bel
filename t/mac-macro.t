#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 3;

{
    is_bel_output("((macro (v) v) 'b)", "b");
    is_bel_output("((macro (v) `(cons ,v 'a)) 'b)", "(b . a)");
    is_bel_output("((fn (x) ((macro (v) `(cons ,v 'a)) x)) 'b)", "(b . a)");
}
