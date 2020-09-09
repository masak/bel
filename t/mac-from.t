#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 2;

my $filename = "siaure";

ok((!-e $filename), "file does not exist");

{
    open(my $OUT, ">", $filename)
        or die "Could not open '$filename' for writing: $!";

    print {$OUT} "bel";

    close($OUT);
}

is_bel_output(qq[(from "$filename" 'foo)], "foo");

END {
    unlink($filename);
}
