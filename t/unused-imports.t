use 5.006;
use strict;
use warnings;

use Test::More;

plan tests => 1;

sub visit {
    my ($dir, $fn_ref, $prefix) = @_;
    $prefix ||= "";

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

my $unused_imports = "";

sub scan_for_unused {
    my ($longname, $shortname) = @_;

    my $contents = "";
    {
        local $/;
        open my $fh, "<", $shortname
            or die "can't open $longname: $!";
        $contents = <$fh>;
    }
    my @imported_functions;
    while ($contents =~ /^use \S+ qw([^;]+)/gm) {
        my $functions = $1;
        for my $function ($functions =~ /\w+/g) {
            push @imported_functions, $function;
        }
    }
    for my $function (@imported_functions) {
        my $n = 0;
        while ($contents =~ /\b\Q$function\E\b/g) {
            $n++;
        }
        if ($n < 2) {
            if (!$unused_imports) {
                $unused_imports = "\n";
            }
            $unused_imports .= "$longname: Unused import $function\n";
        }
    }
}

visit("lib", \&scan_for_unused);

is $unused_imports, "", "there are no unused imports";

