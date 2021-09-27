#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Language::Bel::Test qw(
    test_compilation
);

plan tests => 1;

my $source = "
    (def empty (x))
";

my $target = "
    (bytefunc
      (param!in)
      (param!next)
      (param!last)
      (param!out)
      (%0 := 'nil)
      (return %0))
";

test_compilation($source, $target);

