#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Globals::SVG qw(
    generate
);

plan tests => 1;

{
    my $actual_svg;
    {
        open my $SVG, "<", "images/definitions.svg"
            or die "Couldn't open SVG files: $!";

        my @lines;
        while (my $line = <$SVG>) {
            push @lines, $line;
        }

        close $SVG;

        $actual_svg = join "", @lines;
    }

    my $generated_svg = generate();

    is $actual_svg, $generated_svg, "the definitions SVG is up to date";
}

