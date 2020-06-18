#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output("(bq-letu va (variable va))", "t");
    is_bel_output("(bq-letu va va)", "((nil))");
    is_bel_output("(bq-letu va (id vmark (car va)))", "t");
    is_bel_output("(bq-letu (vb vc) (and (variable vb) (variable vc)))", "t");
    is_bel_output("(bq-letu (vb vc) (list vb vc))", "(((nil)) ((nil)))");
    is_bel_output("(bq-letu (vb vc) (and (id vmark (car vb)) (id vmark (car vc))))", "t");
}
