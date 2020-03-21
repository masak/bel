package Language::Bel::Primitives;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    char_codepoint
    is_char
    is_nil
    is_pair
    is_symbol
    make_pair
    make_symbol
    pair_car
    pair_cdr
    pair_set_cdr
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

sub prim_car {
    my ($object) = @_;

    if (is_nil($object)) {
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

    if (is_nil($object)) {
        return SYMBOL_NIL;
    }
    elsif (!is_pair($object)) {
        die "cdr-on-atom\n";
    }
    else {
        return pair_cdr($object);
    }
}

sub _id {
    my ($first, $second) = @_;

    if (is_symbol($first) && is_symbol($second)) {
        return symbol_name($first) eq symbol_name($second);
    }
    elsif (is_char($first) && is_char($second)) {
        return char_codepoint($first) == char_codepoint($second);
    }
    elsif (is_pair($first) && is_pair($second)) {
        return $first eq $second;
    }
    else {
        return "";
    }
}

sub prim_id {
    my ($first, $second) = @_;

    return _id($first, $second) ? SYMBOL_T : SYMBOL_NIL;
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

sub prim_xdr {
    my ($object, $d_value) = @_;

    if (!is_pair($object)) {
        die "xdr-on-atom\n";
    }
    pair_set_cdr($object, $d_value);
    return $d_value;
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

my %prim_fn = (
    "car" => { fn => \&prim_car, arity => 1 },
    "cdr" => { fn => \&prim_cdr, arity => 1 },
    "id" => { fn => \&prim_id, arity => 2 },
    "join" => { fn => \&prim_join, arity => 2 },
    "type" => { fn => \&prim_type, arity => 1 },
    "xdr" => { fn => \&prim_xdr, arity => 2 },
);

sub PRIM_FN {
    return \%prim_fn;
}

my %primitives = (
    "car" => make_prim("car"),
    "cdr" => make_prim("cdr"),
    "id" => make_prim("id"),
    "join" => make_prim("join"),
    "type" => make_prim("type"),
    "xdr" => make_prim("xdr"),
);

sub PRIMITIVES {
    return \%primitives;
}

our @EXPORT_OK = qw(
    _id
    prim_car
    prim_cdr
    prim_id 
    prim_join
    prim_type
    PRIM_FN
    PRIMITIVES
);

1;
