#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 3;

my $b = Language::Bel->new({ output => undef });

sub is_bel_error {
    my ($expr, $expected_error) = @_;

    eval {
        $b->eval($expr);
    };

    my $actual_error = $@;
    $actual_error =~ s/\n$//;
    is($actual_error, $expected_error, "$expr ==> ERROR[$expected_error]");
}

{
    is_bel_error(q[(list "hello be" . \\l)], "'malformed");
    is_bel_error("(cons \\e . \\l)", "'malformed");
    is_bel_error("(\\e . \\l)", "'malformed");
}
