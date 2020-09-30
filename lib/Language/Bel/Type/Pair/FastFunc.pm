package Language::Bel::Type::Pair::FastFunc;
use base qw(Language::Bel::Type::Pair);

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $pair, $fn, $where_fn) = @_;

    my $obj = {
        pair => $pair,
        fn => $fn,
        where_fn => $where_fn,
    };
    return bless($obj, $class);
}

sub car {
    my ($self) = @_;

    return $self->{pair}->car();
}

sub cdr {
    my ($self) = @_;

    return $self->{pair}->cdr();
}

sub xar {
    my ($self, $car) = @_;

    return $self->{pair}->xar($car);
}

sub xdr {
    my ($self, $cdr) = @_;

    return $self->{pair}->xdr($cdr);
}

sub handles_where {
    my ($self) = @_;

    return ref($self->{where_fn}) eq "CODE";
}

sub apply {
    my ($self, $bel, @args) = @_;

    return $self->{fn}->($bel, @args);
}

sub where_apply {
    my ($self, $bel, @args) = @_;

    return $self->{where_fn}->($bel, @args);
}

1;
