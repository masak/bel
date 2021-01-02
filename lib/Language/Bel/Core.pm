package Language::Bel::Type::Pair;

use 5.006;
use strict;
use warnings;

sub car {
    my ($self) = @_;

    return $self->{car};
}

sub cdr {
    my ($self) = @_;

    return $self->{cdr};
}

sub xar {
    my ($self, $car) = @_;

    return $self->{car} = $car;
}

sub xdr {
    my ($self, $cdr) = @_;

    return $self->{cdr} = $cdr;
}

package Language::Bel::Type::Stream;

sub new {
}

sub read_char {
    my ($self) = @_;

    read($self->{handle}, my $chr, 1);
    return $chr;
}

sub write_char {
    my ($self, $chr) = @_;

    die "'badmode\n"
        unless $self->{mode} eq "out";

    print {$self->{handle}} $chr;
}

sub stat {
    my ($self) = @_;

    return $self->{mode};
}

sub close {
    my ($self) = @_;

    die "'already-closed\n"
        if $self->{mode} eq "closed";

    close($self->{handle})
        or die $!;
    $self->{mode} = "closed";
}

sub mode {
    my ($self) = @_;

    return $self->{mode};
}

package Language::Bel::Core;

use Language::Bel::Type::Symbol;

use Exporter 'import';

sub are_identical {
    my ($first, $second) = @_;

    return
        atoms_are_identical($first, $second)
        ||
        is_pair($first) && is_pair($second)
            && pairs_are_identical($first, $second);
}

sub atoms_are_identical {
    my ($first, $second) = @_;

    return
        is_symbol($first) && is_symbol($second)
            && symbols_are_identical($first, $second)
        ||
        is_char($first) && is_char($second)
            && char_codepoint($first) == char_codepoint($second)
        ||
        is_stream($first) && is_stream($second)
            && streams_are_identical($first, $second);
}

sub char_codepoint {
    my ($char) = @_;

    return $char->{codepoint};
}

sub chars_are_identical {
    my ($first, $second) = @_;

    return char_codepoint($first) == char_codepoint($second);
}

sub is_char {
    my ($object) = @_;

    return $object->isa("Language::Bel::Type::Char");
}

sub is_nil {
    my ($object) = @_;

    return is_symbol_of_name($object, "nil");
}

sub is_pair {
    my ($object) = @_;

    return $object->isa("Language::Bel::Type::Pair");
}

sub is_stream {
    my ($object) = @_;

    return $object->isa("Language::Bel::Type::Stream");
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

    return $object->isa("Language::Bel::Type::Symbol");
}

sub is_symbol_of_name {
    my ($object, $name) = @_;

    return is_symbol($object) && symbol_name($object) eq $name;
}

sub make_char {
    my ($codepoint) = @_;

    return bless(
        { codepoint => $codepoint },
        "Language::Bel::Type::Char"
    );
}

sub make_pair {
    my ($car, $cdr) = @_;

    return bless(
        { car => $car, cdr => $cdr },
        "Language::Bel::Type::Pair",
    );
}

sub make_stream {
    my ($path_str, $mode) = @_;

    # XXX: error handle $mode values

    $mode = symbol_name($mode);

    my $handle;
    if ($mode eq "out") {
        open($handle, ">", $path_str)
            or die "'ioerror\n";
    }
    else {
        open($handle, "<", $path_str)
            or $! =~ /No such file/ and die "'notexist\n"
            or die "'ioerror\n";
    }

    return bless(
        { handle => $handle, mode => $mode },
        "Language::Bel::Type::Stream",
    );
}

sub make_symbol {
    my ($name) = @_;

    return Language::Bel::Type::Symbol->new($name);
}

sub pair_car {
    my ($pair) = @_;

    return $pair->car();
}

sub pair_cdr {
    my ($pair) = @_;

    return $pair->cdr();
}

sub pair_set_car {
    my ($pair, $car) = @_;

    $pair->xar($car);
    return;
}

sub pair_set_cdr {
    my ($pair, $cdr) = @_;

    $pair->xdr($cdr);
    return;
}

sub pairs_are_identical {
    my ($first, $second) = @_;

    return $first eq $second;
}

sub string_value {
    my ($object) = @_;

    my @chars;
    while (is_pair($object)) {
        push @chars, chr(char_codepoint(pair_car($object)));
        $object = pair_cdr($object);
    }
    return join "", @chars;
}

sub symbol_name {
    my ($symbol) = @_;

    return $symbol->{name};
}

sub streams_are_identical {
    my ($first, $second) = @_;

    return $first eq $second;
}

sub symbols_are_identical {
    my ($first, $second) = @_;

    return symbol_name($first) eq symbol_name($second);
}

our @EXPORT_OK = qw(
    are_identical
    atoms_are_identical
    char_codepoint
    chars_are_identical
    is_char
    is_nil
    is_pair
    is_stream
    is_string
    is_symbol
    is_symbol_of_name
    make_char
    make_pair
    make_stream
    make_symbol
    pair_car
    pair_cdr
    pair_set_car
    pair_set_cdr
    pairs_are_identical
    string_value
    symbol_name
    symbols_are_identical
);

1;
