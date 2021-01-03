package Language::Bel::Pair::SignedRat;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    make_pair
    make_symbol
    SYMBOL_NIL
);
use Language::Bel::Pair::RepeatList qw(
    make_repeat_list
);

use Exporter 'import';

sub new {
    my ($class, $sign, $numerator, $denominator) = @_;

    my $obj = {
        sign => $sign,
        numerator => $numerator,
        denominator => $denominator,
        pair => undef,
    };
    return bless($obj, $class);
}

sub reify_if_needed {
    my ($self) = @_;

    if (!$self->{pair}) {
        $self->{pair} = make_pair(
            make_symbol($self->{sign}),
            make_pair(
                make_repeat_list($self->{numerator}),
                make_pair(
                    make_repeat_list($self->{denominator}),
                    SYMBOL_NIL,
                ),
            ),
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

sub sign {
    my ($self) = @_;

    return $self->{sign};
}

sub numerator {
    my ($self) = @_;

    return $self->{numerator};
}

sub denominator {
    my ($self) = @_;

    return $self->{denominator};
}

sub make_signed_rat {
    my ($sign, $numerator, $denominator) = @_;

    return __PACKAGE__->new($sign, $numerator, $denominator);
}

our @EXPORT_OK = qw(
    make_signed_rat
);

1;
