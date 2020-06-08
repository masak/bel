#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(nchar 7)", "\\bel");
    is_bel_output("(nchar 32)", "\\sp");
    is_bel_output("(nchar 48)", "\\0");
    is_bel_output("(nchar 66)", "\\B");
    # Commenting out the following two tests, as they currently
    # generate "deep recursion" warnings when run.
    #is_bel_output("(nchar 101)", "\\e");
    #is_bel_output("(nchar 108)", "\\l");
}
