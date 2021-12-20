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
    (def atom (x)
      (no (id (type x) 'pair)))
";

my $target = "
    (bytefunc
      (%0 := params)
      (%1 := prim!cdr %0)
      (err!if %1 'overargs)
      (%0 := prim!car %0)
      (%0 := prim!type %0)
      (%0 := prim!id %0 'pair)
      (%0 := prim!id %0 'nil)
      (return %0))
";

test_compilation($source, $target);

