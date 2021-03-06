use 5.006;
use strict;
use warnings;

use Test::More;

use Language::Bel::Test qw(
    for_each_line_in_file
    visit
);

plan tests => 3;

my $no_version = "";
my $no_strict = "";
my $no_warnings = "";

sub scan_for_missing_version_strict_warnings {
    my ($longname, $shortname) = @_;

    my $this_module_has_version = 0;
    my $this_module_uses_strict = 0;
    my $this_module_uses_warnings = 0;

    for_each_line_in_file($shortname, sub {
        my ($line) = @_;

        chomp $line;
        if ($line eq "use 5.006;") {
            $this_module_has_version = 1;
        }
        elsif ($line eq "use strict;") {
            $this_module_uses_strict = 1;
        }
        elsif ($line eq "use warnings;") {
            $this_module_uses_warnings = 1;
        }
    });

    if (!$this_module_has_version) {
        if (!$no_version) {
            $no_version .= "\n";
        }
        $no_version .= "$longname: Missing 'use 5.006;' declaration\n";
    }

    if (!$this_module_uses_strict) {
        if (!$no_strict) {
            $no_strict .= "\n";
        }
        $no_strict .= "$longname: Missing 'use strict;' declaration\n";
    }

    if (!$this_module_uses_warnings) {
        if (!$no_warnings) {
            $no_warnings .= "\n";
        }
        $no_warnings .= "$longname: Missing 'use warnings;' declaration\n";
    }

}

visit("lib", \&scan_for_missing_version_strict_warnings);

is $no_version, "", "there are no modules with missing version declarations";
is $no_strict, "", "there are no modules with missing strict declarations";
is $no_warnings, "", "there are no modules with missing warnings declarations";

