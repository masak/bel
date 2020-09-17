#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 10;

{
    is_bel_output("(cells nil)", "nil");
    is_bel_output("(cells \\c)", "nil");
    is_bel_output("(cells '())", "nil");
    is_bel_output("(cells '(nil))", "((nil))");
    is_bel_output("(cells '(a b c))", "((a b c) (b c) (c))");
    is_bel_output("(cells '(a nil c))", "((a nil c) (nil c) (c))");
    is_bel_output("(let L '(a) (xar L L) (len (cells L)))", "2");
    is_bel_output("(let L '(a) (xdr L L) (len (cells L)))", "2");
    is_bel_output("(let L '(a) (xar L L) (len (dups (cells L) id)))", "1");
    is_bel_output("(let L '(a) (xdr L L) (len (dups (cells L) id)))", "1");
}
