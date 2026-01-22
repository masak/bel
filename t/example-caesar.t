#!perl -T
use 5.006;

use strict;
use warnings;

use Test::More;
use Language::Bel::Test;

plan tests => 1;

my $output = output_of_eval_file("t/caesar.bel");

is $output,
    "khoor\n",
    "caesar example works";

