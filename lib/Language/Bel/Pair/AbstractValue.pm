package Language::Bel::Pair::AbstractValue;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    SYMBOL_NIL
);

use Exporter 'import';

sub new {
    my ($class, $payload) = @_;

    my $obj = {
        payload => $payload,
    };
    return bless($obj, $class);
}

sub car {
    my ($self) = @_;

    return SYMBOL_NIL;
}

sub cdr {
    my ($self) = @_;

    return SYMBOL_NIL;
}

sub xar {
    my ($self, $car) = @_;

    return $car;
}

sub xdr {
    my ($self, $cdr) = @_;

    return $cdr;
}

sub is_abstract_value {
    my ($object) = @_;

    return $object->isa(__PACKAGE__);
}

sub make_abstract_value {
    my ($payload) = @_;

    return __PACKAGE__->new($payload);
}

our @EXPORT_OK = qw(
    is_abstract_value
    make_abstract_value
);

1;
