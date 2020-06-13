#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 9;

{
    is_bel_output("smark", "(nil)");
    is_bel_output("(id vmark smark)", "nil");

    is_bel_output("(inwhere nil)", "nil");
    is_bel_output("(inwhere (list (list (list smark))))", "nil");
    is_bel_output("(inwhere (list (list (list smark 'nope))))", "nil");

    is_bel_output("(inwhere (list (list (list smark 'loc t))))", "(t)");
    is_bel_output("(inwhere (list (list (list smark 'loc nil))))", "(nil)");
    is_bel_output("(inwhere (list (list (list smark 'loc 'foo))))", "(foo)");
    is_bel_output("(inwhere (list (list (list smark 'loc))))", "nil");
}
