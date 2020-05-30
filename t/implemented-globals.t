#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::NotYetImplemented;

plan tests => 3;

my %listed = Language::Bel::NotYetImplemented::list();
my %waiting_for;

sub set_difference {
    my ($h1_ref, $h2_ref) = @_;

    my %difference;
    for my $k (keys(%$h1_ref)) {
        if (!exists $h2_ref->{$k}) {
            $difference{$k}++;
        }
    }
    return keys(%difference);
}

my $bel_bel_file = "pg/bel.bel";
open my $BEL_BEL, "<", $bel_bel_file
    or die "Cannot open $bel_bel_file: $!";

sub read_bel_line {
    my $line = <$BEL_BEL> || "";
    $line =~ s/\r?\n$//;
    return $line;
}

read_bel_line()
    for 1..3;

sub read_bel_definition {
    my $definition = "";
    while (my $line = read_bel_line()) {
        $definition .= "$line\n";
    }
    return $definition;
}

my @bel_globals;

until (eof($BEL_BEL)) {
    push(@bel_globals, read_bel_definition());
}

my $n = @bel_globals;

close $BEL_BEL;

my $globals_source_file = "lib/Language/Bel/Globals/Source.pm";
open my $SOURCE, "<", $globals_source_file
    or die "Cannot open $globals_source_file: $!";

sub read_source_line {
    my $line = <$SOURCE> || "";
    $line =~ s/\r?\n$//;
    return $line;
}

sub read_source_until_data {
    while (1) {
        my $line = read_source_line();
        last if $line =~ /__DATA__/;
    }
}

read_source_until_data();

sub read_source_definition {
    my $definition = "";
    while (my $line = read_source_line()) {
        $definition .= "$line\n";
    }
    return $definition;
}

my $i = 0;
my $num_implemented = 0;
while ($i < @bel_globals && !eof($SOURCE)) {
    my $source_definition = read_source_definition();
    my $bel_global = $bel_globals[$i];
    my $name = ($bel_global =~ /^\((?:def|mac|set|form|syn) (\S+)/)
        ? $1
        : "<no name found>";
    my $skip_decl = "; skip $name\n";
    
    if ($source_definition eq $bel_global) {
        $num_implemented++;
    }
    elsif ($source_definition =~ /^; skip \Q$name\E \[waiting for (\w+(?:, \w+)*)\]$/) {
        my $features = $1;
        for my $feature (split /, /, $features) {
            $waiting_for{$feature}++;
        }
    }
    elsif ($name eq "randlen") {
        # make a special exception for `randlen`, which wants `read`
        $num_implemented++;
    }
    else {
        print("source:\n$source_definition\n");
        print("bel:\n$bel_global\n");
        print("skip decl:\n$skip_decl");
        die "Unknown source definition";
    }

    $i++;
}

close $SOURCE;

my $perc = sprintf("%.1f%%", $num_implemented * 100 / $n);

my $readme_file = "README.md";
open my $README, "<", $readme_file
    or die "Cannot open $readme_file $!";

my $found_line = 0;
my $number_in_readme;

while (my $line = <$README>) {
    $line =~ s/\r?\n$//;
    if ($line =~ /^`Language::Bel` currently defines (\d+) of them\.$/) {
        $found_line = 1;
        $number_in_readme = $1;
    }
}

die "Didn't find the line with the number"
    unless $found_line;

is $number_in_readme,
    $num_implemented,
    "the README.md file correctly reports the number of implemented globals";

{
    my $waiting_for_but_not_listed = join ", ", set_difference(\%waiting_for, \%listed);

    is $waiting_for_but_not_listed,
        "",
        "all the features we're waiting for are listed";
}

{
    my $listed_but_not_waiting_for = join ", ", set_difference(\%listed, \%waiting_for);

    is $listed_but_not_waiting_for,
        "",
        "all the listed features are things we're waiting for";
}
