#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output("(type (fu (s r m) s))", "pair");
    is_bel_output(
        "(= (fu (s r m) s) (list (list smark 'fut (list 'lit 'clo nil '(s r m) 's)) nil))",
        "t"
    );
    is_bel_output(
        "(= (fu (s r m) r) (list (list smark 'fut (list 'lit 'clo nil '(s r m) 'r)) nil))",
        "t"
    );
    is_bel_output(
        "(id (car:car (fu (s r m) (cdr s))) smark)",
        "t"
    );
}
