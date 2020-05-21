#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output(q[(when t "OH" " " "HAI")], q["HAI"]);
    is_bel_output(q[(when t "OH")], q["OH"]);
    is_bel_output(q[(when t)], "nil");
    is_bel_output(q[(when nil "OH" " " "HAI")], "nil");
    is_bel_output(q[(when nil "OH")], "nil");
    is_bel_output(q[(when nil)], "nil");
}
