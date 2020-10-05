#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Globals::FastFuncs::Preprocessor qw(
    preprocess
);

plan tests => 1;

{
    my $actual_fastfuncs;
    {
        open my $FASTFUNCS, "<", "lib/Language/Bel/Globals/FastFuncs.pm"
            or die "Couldn't open fastfuncs module: $!";

        my @lines;
        while (my $line = <$FASTFUNCS>) {
            push @lines, $line;
        }

        close $FASTFUNCS;

        $actual_fastfuncs = join("", @lines);
    }
    my $generated_fastfuncs = preprocess();

    is $actual_fastfuncs, $generated_fastfuncs, "the fastfuncs are up to date";
}

