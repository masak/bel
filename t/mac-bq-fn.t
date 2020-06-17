#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("((bq-fn (x) (list x x)) 'a)", "(a a)");
    is_bel_output("((bq-fn (x y) (list x y)) 'a 'b)", "(a b)");
    is_bel_output("((bq-fn () (list 'a 'b 'c)))", "(a b c)");
    is_bel_output("((bq-fn (x) ((fn (y) (list x y)) 'g)) 'f)", "(f g)");
    is_bel_output("((bq-fn () 'irrelevant 'relevant))", "relevant");
    is_bel_error("((bq-fn () (car 'atom) 'never))", "car-on-atom");
}
