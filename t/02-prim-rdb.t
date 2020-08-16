#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 7;

my $filename = "oiwyet";

ok((!-e $filename), "file does not exist");

{
    open(my $OUT, ">", $filename)
        or die "Could not open '$filename' for writing: $!";

    print {$OUT} "zoo";

    close($OUT);
}

is_bel_output(qq[(set s (ops "$filename" 'in))], "<stream>");
is_bel_output("(nof 8 (rdb s))", q["01111010"]);
is_bel_output("(nof 8 (rdb s))", q["01101111"]);
is_bel_output("(nof 8 (rdb s))", q["01101111"]);
is_bel_output("(rdb s)", "eof");

is_bel_error(qq[(let s (ops "$filename" 'out) (rdb s))], "'badmode");

END {
    unlink($filename);
}

