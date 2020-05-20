#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(do (def popx () (let (xa . xd) x (set x xd) xa)) (function popx))", "clo");
    is_bel_output("(do (set x '(nil nil a b c)) (len x))", "5");
    is_bel_output("((yc (fn (self) (fn (v) (if v v (self (popx)))))) (popx))", "a");
    is_bel_output("(len x)", "2");
}
