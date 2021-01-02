package Language::Bel::Type::Pair::Num;
use base qw(Language::Bel::Type::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    make_pair
    make_symbol
    SYMBOL_NIL
);

use Exporter 'import';

sub new {
    my ($class, $real_sr, $imag_sr) = @_;

    my $obj = {
        real_sr => $real_sr,
        imag_sr => $imag_sr,
        pair => undef,
    };
    return bless($obj, $class);
}

sub reify_if_needed {
    my ($self) = @_;

    if (!$self->{pair}) {
        $self->{pair} = make_pair(
            make_symbol("lit"),
            make_pair(
                make_symbol("num"),
                make_pair(
                    $self->{real_sr},
                    make_pair(
                        $self->{imag_sr},
                        SYMBOL_NIL,
                    ),
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

sub make_num {
    my ($real_sr, $imag_sr) = @_;

    return __PACKAGE__->new($real_sr, $imag_sr);
}

our @EXPORT_OK = qw(
    make_num
);

1;
