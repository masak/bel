package Language::Bel::Type::Pair::RepeatList;
use base qw(Language::Bel::Type::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    make_pair
    SYMBOL_NIL
    SYMBOL_T
);

use Exporter 'import';

sub new {
    my ($class, $n) = @_;

    my $obj = {
        n => $n,
        pair => undef,
    };
    return bless($obj, $class);
}

sub reify_if_needed {
    my ($self) = @_;

    if (!$self->{pair}) {
        $self->{pair} = make_pair(
            SYMBOL_T,
            make_repeat_list($self->{n} - 1),
        );
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

sub n {
    my ($self) = @_;

    return $self->{n};
}

sub make_repeat_list {
    my ($n) = @_;

    return $n > 0
        ? __PACKAGE__->new($n)
        : SYMBOL_NIL;
}

our @EXPORT_OK = qw(
    make_repeat_list
);

1;
