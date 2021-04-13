#!perl -T
use 5.006;
use strict;
use warnings;

use Test::More;

use Language::Bel::Test qw(
    for_each_line_in_file
);

plan tests => 1;

my %versions;
my $found_readme_line = 0;

for_each_line_in_file("README.md", sub {
    my ($line, $exit_loop) = @_;

    if ($line =~ /^Language::Bel (\S+) -- \w+\.$/) {
        $found_readme_line = 1;
        ++$versions{$1};
        $exit_loop->();
    }
});

my $found_first_line = 0;
my $found_second_line = 0;

for_each_line_in_file("lib/Language/Bel.pm", sub {
    my ($line) = @_;

    if ($line =~ /^Version (\S+)$/) {
        $found_first_line = 1;
        ++$versions{$1};
    }
    elsif ($line =~ /^our \$VERSION = '([^']+)';$/) {
        $found_second_line = 1;
        ++$versions{$1};
    }
});

die "Didn't find the version line in the README file"
    unless $found_readme_line;

die "Didn't find the first version line in Bel.pm"
    unless $found_first_line;

die "Didn't find the second version line in Bel.pm"
    unless $found_second_line;

my @unique_versions = keys(%versions);

is join(" ", @unique_versions),
    $unique_versions[0],
    "all the versions are the same";
