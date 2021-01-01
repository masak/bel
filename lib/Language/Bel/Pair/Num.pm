package Language::Bel::Pair::Num;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    is_nil
    is_symbol_of_name
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

sub is_num {
    my ($object) = @_;

    return $object->isa(__PACKAGE__);
}

sub make_num {
    my ($real_sr, $imag_sr) = @_;

    return __PACKAGE__->new($real_sr, $imag_sr);
}

sub maybe_get_int {
    my ($bel, $x) = @_;

    # skip past the 'lit' and the 'num'
    $x = $bel->cdr($bel->cdr($x));

    my $xr = $bel->car($x);
    my $xi = $bel->car($bel->cdr($x));

    my $real_part;
    {
        my $xs = $bel->car($xr);
        my $xn = $bel->car($bel->cdr($xr));
        my $xd = $bel->car($bel->cdr($bel->cdr($xr)));

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = $bel->cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = $bel->cdr($xd);
        }

        $real_part = is_symbol_of_name($xs, "+")
            ? $xn_n / $xd_n
            : -$xn_n / $xd_n;
    }

    {
        my $xn = $bel->car($bel->cdr($xi));
        my $xd = $bel->car($bel->cdr($bel->cdr($xi)));

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = $bel->cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = $bel->cdr($xd);
        }

        my $imaginary_part = $xn_n / $xd_n;
        return
            if $imaginary_part != 0;
    }

    return int($real_part);
}

our @EXPORT_OK = qw(
    is_num
    make_num
    maybe_get_int
);

1;
