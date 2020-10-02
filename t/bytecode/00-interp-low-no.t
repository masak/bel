#!perl -T
use 5.006;

use strict;
use warnings;

use Test::More;
use Language::Bel::Test;

plan tests => 1;

my $output = output_of_eval_file("t/bytecode/00-interp-low-no.bel");

is $output,
    "t\nt\nt\nnil\nnil\nnil\nnil\nnil\nnil\nt\n",
    "can interpret the Belfast Low form of the `no` function";

