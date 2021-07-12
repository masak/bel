package Language::Bel::Compiler::Primitives;

use 5.006;
use strict;
use warnings;

use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);

use Exporter 'import';

my $primitives = Language::Bel::Primitives->new({
    output => sub {},
    read_char => sub {},
    err => sub {
        my ($message_str) = @_;

        die "Error during compilation: $message_str\n";
    },
});

sub car {
    my ($pair) = @_;

    return $primitives->prim_car($pair);
}

sub cdr {
    my ($pair) = @_;

    return $primitives->prim_cdr($pair);
}

our @EXPORT_OK = qw(
    car
    cdr
);

1;
