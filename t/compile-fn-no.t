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
    (def no (x)
      (id x nil))
";

my $target = "
    (bytefunc
      (%0 := param!next)
      (param!last)
      (%0 := prim!id %0 'nil)
      (return %0))
";

test_compilation($source, $target);

