#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

{
    is_bel_output(q[(unless t "OH" " " "HAI")], "nil");
    is_bel_output(q[(unless t "OH")], "nil");
    is_bel_output(q[(unless t)], "nil");
    is_bel_output(q[(unless nil "OH" " " "HAI")], q["HAI"]);
    is_bel_output(q[(unless nil "OH")], q["OH"]);
    is_bel_output(q[(unless nil)], "nil");
}
