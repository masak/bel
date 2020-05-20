#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 9;

{
    is_bel_output("templates", "(lit tab)");
    is_bel_output("(tem point x 0 y 0)", "((x lit clo nil nil 0) (y lit clo nil nil 0))");
    is_bel_output("(make point)", "(lit tab (x . 0) (y . 0))");
    is_bel_output("(make point x 1 y 5)", "(lit tab (x . 1) (y . 5))");
    is_bel_output("(let p (make point) p!x)", "0");
    is_bel_output("(let p (make point) (++ p!x))", "1");
    is_bel_output("(let p (make point) (++ p!x) p!x)", "1");
    is_bel_output("(let p (make point x 1) (swap p!x p!y) p)", "(lit tab (x . 0) (y . 1))");
    is_bel_output(
        "(with (p (make point y 1) q (make point x 1 y 5) above (of > !y)) (above q p (make point)))",
        "t",
    );
}
