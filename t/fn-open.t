#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

is_bel_output("(len cbuf)", "1");
is_bel_output(q[(type (open "testfile" 'out))], "stream");
is_bel_output("(len cbuf)", "2");

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

is_bel_output(qq[(type (open "$filename" 'in))], "stream");
is_bel_output("(len cbuf)", "3");

END {
    unlink($filename);
}
