package Language::Bel::Primitives;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    char_codepoint
    is_char
    is_nil
    is_pair
    is_stream
    is_symbol
    make_char
    make_pair
    make_stream
    make_symbol
    pair_car
    pair_cdr
    pair_set_car
    pair_set_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_CHAR
    SYMBOL_NIL
    SYMBOL_PAIR
    SYMBOL_STREAM
    SYMBOL_SYMBOL
    SYMBOL_T
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

sub prim_coin {
    return rand() < 0.5
        ? SYMBOL_NIL
        : SYMBOL_T;
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

sub prim_nom {
    my ($value) = @_;

    if (!is_symbol($value)) {
        die "not-a-symbol\n";
    }

    my $result = SYMBOL_NIL;
    for my $char (reverse(split //, symbol_name($value))) {
        $result = make_pair(
            make_char(ord($char)),
            $result,
        );
    }
    return $result;
}

sub prim_ops {
    my ($path, $mode) = @_;

    my @stack;
    while (is_pair($path)) {
        my $elem = prim_car($path);
        die "not-a-string"
            unless is_char($elem);
        push @stack, chr(char_codepoint($elem));
        $path = prim_cdr($path);
    }
    my $path_str = join("", @stack);

    if (!is_symbol($mode)) {
        die "not-a-symbol\n";
    }

    return make_stream($path_str, $mode);
}

sub prim_sym {
    my ($value) = @_;

    my @stack;
    while (is_pair($value)) {
        my $elem = prim_car($value);
        die "not-a-string"
            unless is_char($elem);
        push @stack, chr(char_codepoint($elem));
        $value = prim_cdr($value);
    }
    die "not-a-string"
        unless is_nil($value);

    my $name = join("", @stack);
    return make_symbol($name);
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
    elsif (is_stream($value)) {
        return SYMBOL_STREAM;
    }
    else {
        die "unknown type";
    }
}

sub prim_wrb {
}

sub prim_xar {
    my ($object, $a_value) = @_;

    if (!is_pair($object)) {
        die "xar-on-atom\n";
    }
    pair_set_car($object, $a_value);
    return $a_value;
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
    "coin" => { fn => \&prim_coin, arity => 0 },
    "id" => { fn => \&prim_id, arity => 2 },
    "join" => { fn => \&prim_join, arity => 2 },
    "nom" => { fn => \&prim_nom, arity => 1 },
    "ops" => { fn => \&prim_ops, arity => 2 },
    "sym" => { fn => \&prim_sym, arity => 1 },
    "type" => { fn => \&prim_type, arity => 1 },
    "wrb" => { fn => \&prim_wrb, arity => 2 },
    "xar" => { fn => \&prim_xar, arity => 2 },
    "xdr" => { fn => \&prim_xdr, arity => 2 },
);

sub PRIM_FN {
    return \%prim_fn;
}

my %primitives;
for my $name (keys %prim_fn) {
    $primitives{$name} = make_prim($name);
}

sub PRIMITIVES {
    return \%primitives;
}

our @EXPORT_OK = qw(
    _id
    prim_car
    prim_cdr
    prim_coin
    prim_id 
    prim_join
    prim_nom
    prim_ops
    prim_sym
    prim_type
    prim_wrb
    prim_xar
    prim_xdr
    PRIM_FN
    PRIMITIVES
);

1;
