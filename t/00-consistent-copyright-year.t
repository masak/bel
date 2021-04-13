use 5.006;
use strict;
use warnings;

use Test::More;

use Language::Bel::Test qw(
    for_each_line_in_file
);

my @FILES = qw(README README.md lib/Language/Bel.pm);

plan tests => scalar(@FILES);

my $year = (localtime())[5] + 1900;

for my $file (@FILES) {
    my $found_year = 0;
    for_each_line_in_file($file, sub {
        my ($line, $exit_loop) = @_;
        if ($line =~ /\b$year\b/) {
            $found_year = 1;
            $exit_loop->();
        }
    });

    ok $found_year, "found current year in $file";
}

