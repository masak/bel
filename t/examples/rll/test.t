#!perl
use 5.006;

use strict;
use warnings;
use Test::More;

plan tests => 1;

my $output = `perl -Ilib bin/bel t/examples/rll/reverse-linked-list.bel`;

is $output, "<linked-list (5 4 3 2 1)>\n", "reverse-linked-list example works";
