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

sub is_nil {
    my ($object) = @_;

    return is_symbol_of_name($object, "nil");
}

sub is_pair {
    my ($object) = @_;

    return ref($object) eq "Language::Bel::Type::Pair";
}

sub is_string {
    my ($object) = @_;

    while (is_pair($object)) {
        return unless is_char(pair_car($object));
        $object = pair_cdr($object);
    }
    return is_nil($object);
}

sub is_symbol {
    my ($object) = @_;

    return ref($object) eq "Language::Bel::Type::Symbol";
}

sub is_symbol_of_name {
    my ($object, $name) = @_;

    return is_symbol($object) && symbol_name($object) eq $name;
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

sub pair_set_cdr {
    my ($pair, $cdr) = @_;

    $pair->{cdr} = $cdr;
    return;
}

sub string_value {
    my ($object) = @_;

    my @chars;
    while (is_pair($object)) {
        push @chars, char_name(pair_car($object));
        $object = pair_cdr($object);
    }
    return join "", @chars;
}

sub symbol_name {
    my ($symbol) = @_;

    return $symbol->{name};
}

our @EXPORT_OK = qw(
    char_name
    is_char
    is_nil
    is_pair
    is_string
    is_symbol
    is_symbol_of_name
    make_char
    make_pair
    make_symbol
    pair_car
    pair_cdr
    pair_set_cdr
    string_value
    symbol_name
);


