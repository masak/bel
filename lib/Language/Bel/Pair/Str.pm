package Language::Bel::Pair::Str;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    make_char
    make_pair
    SYMBOL_NIL
);

use Exporter 'import';

sub new {
    my ($class, $string) = @_;

    die "Empty string"
        unless length($string);

    my $obj = {
        string => $string,
        pair => undef,
    };
    return bless($obj, $class);
}

sub reify_if_needed {
    my ($self) = @_;

    if (!$self->{pair}) {
        $self->{pair} = make_pair(
            make_char(ord($self->{string})),
            make_str(substr($self->{string}, 1)),
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

sub string {
    my ($self) = @_;

    return $self->{string};
}

sub is_str {
    my ($object) = @_;

    return $object->isa(__PACKAGE__);
}

sub make_str {
    my ($string) = @_;

    return length($string) > 0
        ? __PACKAGE__->new($string)
        : SYMBOL_NIL;
}

our @EXPORT_OK = qw(
    is_str
    make_str
);

1;
