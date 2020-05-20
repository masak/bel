#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("((isa 'clo) (fn (x) x))", "t");
    is_bel_output("((isa 'clo) [_])", "t");
    is_bel_output("((isa 'clo) idfn)", "t");
    is_bel_output("((isa 'prim) car)", "t");
    is_bel_output("((isa 'clo) nil)", "nil");
    is_bel_output("((isa 'clo) 'c)", "nil");
    is_bel_output("((isa 'clo) '(a b c))", "nil");
    is_bel_output("((isa 'mac) def)", "t");
}
