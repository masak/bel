#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Language::Bel::Bytecode qw(
    belify_bytefunc
);
use Language::Bel::Compiler qw(
    compile
);

plan tests => 2;

sub bc {
    my ($bel_source) = @_;

    return belify_bytefunc(compile($bel_source));
}

sub deindent {
    my ($text) = @_;

    my $result = join("\n", map { $_ && substr($_, 4) } split(/\n/, $text));
    $result =~ s/^\n//;
    return $result;
}

sub test_compilation {
    my ($source, $target) = @_;
    $source =~ /^\(def (\S+)/
        or die "Couldn't parse out the name from '$source'";
    my $name = $1;

    is bc($source), $target, "compilation of `$name`";
}

my $source = deindent("
    (def atom (x)
      (no (id (type x) 'pair)))
");

my $target = deindent("
    (bytefunc 1
      (param!in)
      (%0 := param!next)
      (param!last)
      (param!out)
      (%0 := prim!type %0)
      (%0 := prim!id %0 'pair)
      (%0 := prim!id %0 'nil)
      (return %0))
");

test_compilation($source, $target);

