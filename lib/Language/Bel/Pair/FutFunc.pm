package Language::Bel::Pair::FutFunc;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Reader qw(
    read_whole
);

use Exporter 'import';

sub new {
    my ($class, $source, $fn) = @_;

    my $obj = {
        source => $source,
        pair => undef,
        fn => $fn,
    };
    return bless($obj, $class);
}

sub reify_if_needed {
    my ($self) = @_;

    if (!$self->{pair}) {
        $self->{pair} = read_whole($self->{source});
    }
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
    my ($pair, $fn) = @_;

    return __PACKAGE__->new($pair, $fn);
}

our @EXPORT_OK = qw(
    make_futfunc
);

1;
