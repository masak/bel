package Language::Bel::Pair::FutFunc;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub new {
    my ($class, $pair_factory, $fn) = @_;

    my $obj = {
        pair_factory => $pair_factory,
        pair => undef,
        fn => $fn,
    };
    return bless($obj, $class);
}

sub reify_if_needed {
    my ($self) = @_;

    $self->{pair} ||= $self->{pair_factory}->();
}

sub car {
    my ($self) = @_;

    $self->reify_if_needed();
    return $self->{pair}->car();
}

sub cdr {
    my ($self) = @_;

    $self->reify_if_needed();
    return $self->{pair}->cdr();
}

sub xar {
    my ($self, $car) = @_;

    $self->reify_if_needed();
    return $self->{pair}->xar($car);
}

sub xdr {
    my ($self, $cdr) = @_;

    $self->reify_if_needed();
    return $self->{pair}->xdr($cdr);
}

sub apply {
    my ($self) = @_;

    return $self->{fn}->();
}

sub make_futfunc {
    my ($pair_factory, $fn) = @_;

    return __PACKAGE__->new($pair_factory, $fn);
}

our @EXPORT_OK = qw(
    make_futfunc
);

1;
