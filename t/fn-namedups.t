#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(let L '(a) (len (namedups L)))", "0");
    is_bel_output("(let L '(a b c) (len (namedups L)))", "0");
    is_bel_output("(let L '(a) (xar L L) (len (namedups L)))", "1");
    is_bel_output("(let L '(a) (xdr L L) (len (namedups L)))", "1");
}
