#!perl -T
use 5.006;

use strict;
use warnings;

use Test::More;
use Language::Bel::Test;

plan tests => 1;

my $output = output_of_eval_file("t/board-movements.bel");

is $output,
    "(5 1) \n",  # note the space at the end; this is spec
    "board-movements example works";

