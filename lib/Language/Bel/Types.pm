package Language::Bel::Types;

use Language::Bel::Type::Char;
use Language::Bel::Type::Pair;
use Language::Bel::Type::Symbol;

use Exporter 'import';

sub char_name {
    my ($char) = @_;

    return $char->{name};
}

sub is_char {
    my ($object) = @_;

    return ref($object) eq "Language::Bel::Type::Char";
}

sub is_pair {
    my ($object) = @_;

    return ref($object) eq "Language::Bel::Type::Pair";
}

sub is_symbol {
    my ($object) = @_;

    return ref($object) eq "Language::Bel::Type::Symbol";
}

sub make_char {
    my ($name) = @_;

    return Language::Bel::Type::Char->new($name);
}

sub make_pair {
    my ($car, $cdr) = @_;

    return Language::Bel::Type::Pair->new($car, $cdr);
}

sub make_symbol {
    my ($name) = @_;

    return Language::Bel::Type::Symbol->new($name);
}

sub pair_car {
    my ($pair) = @_;

    return $pair->{car};
}

sub pair_cdr {
    my ($pair) = @_;

    return $pair->{cdr};
}

sub symbol_name {
    my ($symbol) = @_;

    return $symbol->{name};
}

our @EXPORT_OK = qw(
    char_name
    is_char
    is_pair
    is_symbol
    make_char
    make_pair
    make_symbol
    pair_car
    pair_cdr
    symbol_name
);

