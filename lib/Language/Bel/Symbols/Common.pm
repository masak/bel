package Language::Bel::Symbols::Common;

use Language::Bel::Types qw(make_symbol);
use Exporter 'import';

my $symbol_a = make_symbol("a");

sub SYMBOL_A {
    return $symbol_a;
}

my $symbol_bquote = make_symbol("bquote");

sub SYMBOL_BQUOTE {
    return $symbol_bquote;
}

my $symbol_char = make_symbol("char");

sub SYMBOL_CHAR {
    return $symbol_char;
}

my $symbol_comma = make_symbol("comma");

sub SYMBOL_COMMA {
    return $symbol_comma;
}

my $symbol_comma_at = make_symbol("comma-at");

sub SYMBOL_COMMA_AT {
    return $symbol_comma_at;
}

my $symbol_d = make_symbol("d");

sub SYMBOL_D {
    return $symbol_d;
}

my $symbol_nil = make_symbol("nil");

sub SYMBOL_NIL {
    return $symbol_nil;
}

my $symbol_pair = make_symbol("pair");

sub SYMBOL_PAIR {
    return $symbol_pair;
}

my $symbol_quote = make_symbol("quote");

sub SYMBOL_QUOTE {
    return $symbol_quote;
}

my $symbol_symbol = make_symbol("symbol");

sub SYMBOL_SYMBOL {
    return $symbol_symbol;
}

my $symbol_t = make_symbol("t");

sub SYMBOL_T {
    return $symbol_t;
}

our @EXPORT_OK = qw(
    SYMBOL_A
    SYMBOL_BQUOTE
    SYMBOL_CHAR
    SYMBOL_COMMA
    SYMBOL_COMMA_AT
    SYMBOL_D
    SYMBOL_NIL 
    SYMBOL_PAIR
    SYMBOL_QUOTE
    SYMBOL_SYMBOL
    SYMBOL_T
);

1;
