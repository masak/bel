#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 1;

my $actual_output = "";
my $b1 = Language::Bel->new({ output => sub {
    my ($string) = @_;
    $actual_output = "$actual_output$string";
} });
my $b2 = Language::Bel->new({ output => sub {} });

$b1->read_eval_print("(set xyzzy 'right)");
$b2->read_eval_print("(set xyzzy 'wrong)");

$actual_output = "";
$b1->read_eval_print("xyzzy");

is($actual_output, "right\n", "two Bel instances have distinct globals and don't interfere");
