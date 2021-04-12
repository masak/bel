use 5.006;
use strict;
use warnings;

use Test::More;

plan tests => 2;

my $file = "lib/Language/Bel/Globals/FastFuncs.pm";
open my $fh, "<", $file
    or die "can't open $file: $!";

my %defined_fastfuncs;
my %exported_fastfuncs;
my $interested = 0;

while (my $line = <$fh>) {
    $line =~ s/\r\n$//;

    if ($line =~ /^sub (fastfunc__\w+)\b/) {
        my $name = $1;
        $defined_fastfuncs{$name} = 1;
    }

    if ($line =~ /^our \@EXPORT_OK = qw\($/) {
        $interested = 1;
    }
    elsif ($interested && $line =~ /^\s{4}(\w+)/) {
        my $name = $1;
        $exported_fastfuncs{$name} = 1;
    }
    elsif ($line =~ /^\);/) {
        $interested = 0;
    }
}

close $fh
    or die "can't close $file";

my @defined_not_exported;
for my $ff (keys %defined_fastfuncs) {
    if (!exists $exported_fastfuncs{$ff}) {
        push @defined_not_exported, $ff;
    }
}

is join(" ", @defined_not_exported),
    "",
    "all defined fastfuncs are exported";

my @exported_not_defined;
for my $ff (keys %exported_fastfuncs) {
    if (!exists $defined_fastfuncs{$ff}) {
        push @exported_not_defined, $ff;
    }
}

is join(" ", @exported_not_defined),
    "",
    "all exported fastfuncs are defined";

