#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 4;

{
    is_bel_output(q[(cut "foobar" 2 4)], q["oob"]);
    is_bel_output(q[(cut "foobar" 2 -1)], q["ooba"]);
    is_bel_output(q[(cut "foobar" 2)], q["oobar"]);
    is_bel_output(q[(cut "foobar")], q["foobar"]);
}
