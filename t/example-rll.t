#!perl -T
use 5.006;

use strict;
use warnings;

use Test::More;
use Language::Bel::Test;

plan tests => 1;

my $output = output_of_eval_file("t/reverse-linked-list.bel");

is $output,
    "<linked-list (5 4 3 2 1)>\n",
    "reverse-linked-list example works";

