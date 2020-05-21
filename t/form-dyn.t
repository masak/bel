#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_error("(let f (fn () d) (f))", "('unboundb d)");
    is_bel_output("(let f (fn () d) (dyn d 'hai (f)))", "hai");
    is_bel_output("(dyn d 'yes d)", "yes");
    is_bel_output("(dyn d 'one (cons (dyn d 'two d) d))", "(two . one)");
    is_bel_output("(let v 'lexical (dyn v 'dynamic v))", "dynamic");
    is_bel_output("(dyn v 'dynamic (let v 'lexical v))", "dynamic");
}
