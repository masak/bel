use 5.006;
use strict;
use warnings;

use Test::More;

my @FILES = qw(README README.md lib/Language/Bel.pm);

plan tests => scalar(@FILES);

my $year = (localtime())[5] + 1900;

for my $file (@FILES) {
    open my $fh, "<", $file
        or die "can't open $file: $!";

    my $found_year = 0;
    while (my $line = <$fh>) {
        $line =~ s/\r?\n$//;

        if ($line =~ /\b$year\b/) {
            $found_year = 1;
            last;
        }
    }

    ok $found_year, "found current year in $file";
    
    close $fh
        or die "can't close $file";
}

