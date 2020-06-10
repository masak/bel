#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;
use Language::Bel::NotYetImplemented;

plan tests => 2;

open my $README, "<", "README.md"
    or die "Couldn't open README.md for reading: $!";

my %readme_list;
my $looking = 0;
while (my $line = <$README>) {
    $line =~ s/\r\n$//;
    if ($line eq "A summary of the remaining big features:") {
        $looking = 1;
    }
    elsif ($line =~ /^\* \*\*(\w+)\*\*/) {
        my $feature = lc($1);
        $readme_list{$feature}++;
    }
    elsif ($line eq "## Contributing") {
        $looking = 0;
        last;
    }
}

close $README;

my %nyi_list = Language::Bel::NotYetImplemented::list();

my %readme_list_not_in_nyi = %readme_list;
delete @readme_list_not_in_nyi{keys(%nyi_list)};

my %nyi_list_not_in_readme = %nyi_list;
delete @nyi_list_not_in_readme{keys(%readme_list)};

is join(" ", keys(%readme_list_not_in_nyi)), "", "all README features are in NYI";
is join(" ", keys(%nyi_list_not_in_readme)), "", "all NYI features are in README";
