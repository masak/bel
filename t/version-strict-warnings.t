use 5.006;
use strict;
use warnings;

use Test::More;

plan tests => 3;

sub visit {
    my ($dir, $fn_ref, $prefix) = @_;
    $prefix ||= "";

    # un-taint $dir
    $dir =~ /^(\w+)$/;
    $dir = $1;
    chdir($dir);

    for my $file (<*>) {
        my $name = "$prefix$dir/$file";
        if ($name =~ /\.pm$/) {
            $fn_ref->($name, $file);
        }

        if (-d $file) {
            visit($file, $fn_ref, "$prefix$dir/");
        }
    }
    chdir("..");
}

my $no_version = "";
my $no_strict = "";
my $no_warnings = "";

sub scan_for_missing_version_strict_warnings {
    my ($longname, $shortname) = @_;

    open my $fh, "<", $shortname
        or die "can't open $longname: $!";

    my $this_module_has_version = 0;
    my $this_module_uses_strict = 0;
    my $this_module_uses_warnings = 0;

    while (my $line = <$fh>) {
        $line =~ s/\r?\n$//;

        if ($line eq "use 5.006;") {
            $this_module_has_version = 1;
        }
        elsif ($line eq "use strict;") {
            $this_module_uses_strict = 1;
        }
        elsif ($line eq "use warnings;") {
            $this_module_uses_warnings = 1;
        }
    }

    close $fh;

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

