#!perl -T
use 5.006;

use strict;
use warnings;

use Test::More;
use Language::Bel::Test;

plan tests => 3;

my $output = output_of_eval_file("t/nondet-parsing.bel");

my @lines = split(/\n/, $output);

is scalar(@lines), 2, "anticipated number of lines of output";
is $lines[0], "(seq \\a seq \\a \\a) ", "first line";
is $lines[1], "(seq seq \\a \\a \\a) ", "second line";

