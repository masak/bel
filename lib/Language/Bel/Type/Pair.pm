package Language::Bel::Type::Pair;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $car, $cdr) = @_;

    my $obj = { car => $car, cdr => $cdr };
    return bless($obj, $class);
}

sub car {
    my ($self) = @_;

    return $self->{car};
}

sub cdr {
    my ($self) = @_;

    return $self->{cdr};
}

sub xar {
    my ($self, $car) = @_;

    return $self->{car} = $car;
}

sub xdr {
    my ($self, $cdr) = @_;

    return $self->{cdr} = $cdr;
}

1;
