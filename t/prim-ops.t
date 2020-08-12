#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 5;

is_bel_output(q[(ops "testfile" 'out)], "<stream>");
is_bel_output(q[(type (ops "testfile" 'out))], "stream");

END {
    unlink("testfile");
}

my $filename = "fwniun";

ok((!-e $filename), "file does not exist");

{
    open(my $OUT, ">", $filename)
        or die "Could not open '$filename' for writing: $!";

    print {$OUT} "bel";

    close($OUT);
}

is_bel_output(qq[(ops "$filename" 'in)], "<stream>");
is_bel_output(qq[(type (ops "$filename" 'in))], "stream");

END {
    unlink($filename);
}
