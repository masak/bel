package Language::Bel::Pair::FastOperative;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub new {
    my ($class, $pair, $fn) = @_;

    my $obj = {
        pair => $pair,
        fn => $fn,
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

sub apply {
    my ($self, $bel, $denv, @args) = @_;

    return $self->{fn}->($bel, $denv, @args);
}

sub is_fastoperative {
    my ($object) = @_;

    return $object->isa(__PACKAGE__);
}

sub make_fastoperative {
    my ($pair, $fn) = @_;

    return __PACKAGE__->new($pair, $fn);
}

our @EXPORT_OK = qw(
    is_fastoperative
    make_fastoperative
);

1;
