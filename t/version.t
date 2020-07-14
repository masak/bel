#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

my %versions;

my $readme_file = "README.md";
open my $README, "<", $readme_file
    or die "Cannot open $readme_file: $!";

my $found_readme_line = 0;

while (my $line = <$README>) {
    $line =~ s/\r?\n$//;
    if ($line =~ /^Language::Bel (\S+) -- \w+\.$/) {
        $found_readme_line = 1;
        ++$versions{$1};
    }
}

close $README;

my $bel_pm_file = "lib/Language/Bel.pm";
open my $BEL_PM_FILE, "<", $bel_pm_file
    or die "Cannot open $bel_pm_file: $!";

my $found_first_line = 0;
my $found_second_line = 0;

while (my $line = <$BEL_PM_FILE>) {
    $line =~ s/\r?\n$//;
    if ($line =~ /^Version (\S+)$/) {
        $found_first_line = 1;
        ++$versions{$1};
    }
    elsif ($line =~ /^our \$VERSION = '([^']+)';$/) {
        $found_second_line = 1;
        ++$versions{$1};
    }
}

close $BEL_PM_FILE;

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
