package Language::Bel::Primitives;

use Language::Bel::Types qw(
    char_name
    is_char
    is_pair
    is_symbol
    make_pair
    make_symbol
    pair_car
    pair_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_CHAR
    SYMBOL_NIL
    SYMBOL_PAIR
    SYMBOL_T
    SYMBOL_SYMBOL
);
use Exporter 'import';

sub lift_boolean {
    my ($bool) = @_;

    return $bool ? SYMBOL_T : SYMBOL_NIL;
}

sub prim_car {
    my ($object) = @_;

    if (is_symbol($object) && symbol_name($object) eq "nil") {
        return SYMBOL_NIL;
    }
    elsif (!is_pair($object)) {
        die "car-on-atom\n";
    }
    else {
        return pair_car($object);
    }
}

sub prim_cdr {
    my ($object) = @_;

    if (is_symbol($object) && symbol_name($object) eq "nil") {
        return SYMBOL_NIL;
    }
    elsif (!is_pair($object)) {
        die "cdr-on-atom\n";
    }
    else {
        return pair_cdr($object);
    }
}

sub prim_id {
    my ($first, $second) = @_;

    if (is_symbol($first) && is_symbol($second)) {
        return lift_boolean(symbol_name($first) eq symbol_name($second));
    }
    elsif (is_char($first) && is_char($second)) {
        return lift_boolean(char_name($first) eq char_name($second));
    }
    elsif (is_pair($first) && is_pair($second)) {
        return lift_boolean($first eq $second);
    }
    else {
        return lift_boolean("");
    }
}

sub prim_join {
    my ($first, $second) = @_;

    return make_pair($first, $second);
}

sub prim_type {
    my ($value) = @_;

    if (is_symbol($value)) {
        return SYMBOL_SYMBOL;
    }
    elsif (is_pair($value)) {
        return SYMBOL_PAIR;
    }
    elsif (is_char($value)) {
        return SYMBOL_CHAR;
    }
    else {
        die "unknown type";
    }
}

sub make_prim {
    my ($name) = @_;

    return make_pair(
        make_symbol("lit"),
        make_pair(
            make_symbol("prim"),
            make_pair(
                make_symbol($name),
                SYMBOL_NIL,
            ),
        ),
    );
}

my %primitives = (
    "car" => make_prim("car"),
    "cdr" => make_prim("cdr"),
    "id" => make_prim("id"),
    "join" => make_prim("join"),
    "type" => make_prim("type"),
);

sub PRIMITIVES {
    return \%primitives;
}

our @EXPORT_OK = qw(
    prim_car
    prim_cdr
    prim_id 
    prim_join
    prim_type
    PRIMITIVES
);

1;
