#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    my $x1 = "(cons (list smark 'bind '(x . 1)) nil)";
    my $x2 = "(cons (list smark 'bind '(x . 2)) nil)";
    my $y1 = "(cons (list smark 'bind '(y . 1)) nil)";

    is_bel_output("(binding 'x nil)", "nil");
    is_bel_output(
        "(binding 'x (list $y1))",
        "nil"
    );
    is_bel_output(
        "(binding 'x (list $x2))",
        "(x . 2)"
    );
    is_bel_output(
        "(binding 'x (list $y1 $x2))",
        "(x . 2)"
    );
    is_bel_output(
        "(binding 'x (list $x2 $y1))",
        "(x . 2)"
    );
    is_bel_output(
        "(binding 'x (list $x1 $x2))",
        "(x . 1)"
    );
}
