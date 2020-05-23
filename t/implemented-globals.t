#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

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
    elsif ($source_definition eq $skip_decl) {
        # we are allowing this one to be skipped
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

