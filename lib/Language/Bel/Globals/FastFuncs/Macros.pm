package Language::Bel::Globals::FastFuncs::Macros;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub CALL {
    my ($fn, @args) = @_;
}

sub GENERATE_WHERE {
    my () = @_;
}

sub IF {
    my ($condition, $body) = @_;
}

sub ITERATE_FORWARD {
    my ($variable, $list, $body) = @_;
}

sub ITERATE_FORWARD_OF {
    my ($variable, $pair, $list, $body) = @_;
}

sub NIL {
    my () = @_;
}

sub T {
    my () = @_;
}

sub UNLESS {
    my ($condition, $body) = @_;
}

our @EXPORT = qw(
    CALL
    GENERATE_WHERE
    IF
    ITERATE_FORWARD
    ITERATE_FORWARD_OF
    NIL
    T
    UNLESS
);

1;
