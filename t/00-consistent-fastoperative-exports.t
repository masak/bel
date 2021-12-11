use 5.006;
use strict;
use warnings;

use Test::More;

use Language::Bel::Test qw(
    for_each_line_in_file
);

plan tests => 2;

my $file = "lib/Language/Bel/Globals/FastOperatives.pm";

my %defined_fastoperatives;
my %exported_fastoperatives;
my $interested = 0;

for_each_line_in_file($file, sub {
    my ($line) = @_;

    if ($line =~ /^sub (fastoperative__\w+)\b/) {
        my $name = $1;
        $defined_fastoperatives{$name} = 1;
    }

    if ($line =~ /^our \@EXPORT_OK = qw\($/) {
        $interested = 1;
    }
    elsif ($interested && $line =~ /^\s{4}(\w+)/) {
        my $name = $1;
        $exported_fastoperatives{$name} = 1;
    }
    elsif ($line =~ /^\);/) {
        $interested = 0;
    }
});

my @defined_not_exported;
for my $ff (keys %defined_fastoperatives) {
    if (!exists $exported_fastoperatives{$ff}) {
        push @defined_not_exported, $ff;
    }
}

is join(" ", @defined_not_exported),
    "",
    "all defined fastoperatives are exported";

my @exported_not_defined;
for my $ff (keys %exported_fastoperatives) {
    if (!exists $defined_fastoperatives{$ff}) {
        push @exported_not_defined, $ff;
    }
}

is join(" ", @exported_not_defined),
    "",
    "all exported fastoperatives are defined";

