#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 18;

{
    is_bel_output("(type prims)", "pair");
    is_bel_output("(all pair prims)", "t");
    is_bel_output("(if (mem 'coin (1 (rev prims))) t)", "t");
    for my $name (qw( car cdr type sym nom rdb cls stat sys )) {
        is_bel_output("(if (mem '$name (2 (rev prims))) t)", "t");
    }
    for my $name (qw( id join xar xdr wrb ops )) {
        is_bel_output("(if (mem '$name (3 (rev prims))) t)", "t");
    }
}
