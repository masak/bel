#!perl -T
use 5.006;

use strict;
use warnings;

use Test::More;
use Language::Bel::Test;

plan tests => 4;

my $output = output_of_eval_file("t/board-movements.bel");

my @lines = split(/\n/, $output);

# the spaces at the end of the output are spec; they are due to `prn`
is $lines[0], "(5 1) ", "a valid sequence of moves";
is $lines[1], "impossible-move ", "trying to leave the board";
is $lines[2], "illegal-command ", "issuing an unknown command";
is $lines[3], "(3 1) ", "quit command but not last";

