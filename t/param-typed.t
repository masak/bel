#!perl -w
# -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 8;

{
    is_bel_output("((lit clo nil ((t xs pair)) xs) (join))", "(nil)");
    is_bel_error("((lit clo nil ((t xs pair)) xs) 'a)", "'mistype");
    is_bel_output("((fn ((t xs pair)) xs) (join))", "(nil)");
    is_bel_error("((fn ((t xs pair)) xs) 'a)", "'mistype");
    is_bel_error("((fn ((o (t (x . y) [caris _ 'a]) '(a . b))) x) '(b b))",
        "'mistype");
    is_bel_output("((fn ((o (t (x . y) [caris _ 'a]) '(a . b))) x))", "a");
    is_bel_output(
        "(let srrecip (fn (s (t n [~= _ nil]) d) (list s d n)) " .
        "(srrecip '+ '(t t) '(t t t)))",
        "(+ (t t t) (t t))");
    is_bel_error(
        "(let srrecip (fn (s (t n [~= _ nil]) d) (list s d n)) " .
        "(srrecip '+ nil '(t t t)))",
        "'mistype");
}
