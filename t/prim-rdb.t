#!perl -T
use 5.006;
use strict;
use warnings;

BEGIN {
    {
        open(my $OUT, ">", "temp3627")
            or die "Could not open 'temp3627' for writing: $!";

        print {$OUT} "zoo";

        close($OUT);
    }
}

use Language::Bel::Test::DSL;

__DATA__

> (nof 8 (rdb nil))
"01000010"

> (set s (ops "temp3627" 'in))
<stream>

> (nof 8 (rdb s))
"01111010"

> (nof 8 (rdb s))
"01101111"

> (nof 8 (rdb s))
"01101111"

> (rdb s)
eof

> (let s (ops "temp3627" 'out)
    (rdb s))
!ERROR: badmode

!END: unlink("temp3627");

