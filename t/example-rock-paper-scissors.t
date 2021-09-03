#!perl -T
use 5.006;

use strict;
use warnings;

use Test::More;
use Language::Bel::Test;

plan tests => 4;

my $output = output_of_eval_file("t/rock-paper-scissors.bel");

my @lines = split(/\n/, $output);

is scalar(@lines), 3, "anticipated number of lines of output";
ok $lines[0] =~ /^Player 1: (rock|paper|scissors)$/,
   "valid player 1 move";
ok $lines[1] =~ /^Player 2: (rock|paper|scissors)$/,
   "valid player 2 move";
ok $lines[2] =~ /^Result: (player [12] wins|it's a tie)$/,
   "valid result";

