#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(okstack nil)", "t");
    is_bel_output("(okstack '(a))", "nil");
    is_bel_output("(okstack '((b)))", "nil");
    is_bel_output("(okstack '((c ((x . y)))))", "t");
    is_bel_output("(okstack '((d ((x . y) (z . w)))))", "t");
    is_bel_output("(okstack '((e nil) (f ((m . n)))))", "t");
}
