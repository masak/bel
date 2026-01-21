package Language::Bel::Compiler::Gensym;

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    is_symbol
    symbol_name
);

use Exporter 'import';

my $unique_gensym_index = 0;

my $GENSYM_PREFIX = "gensym_";

sub gensym {
    return $GENSYM_PREFIX . sprintf("%04d", ++$unique_gensym_index);
}

sub starts_with {
    my ($string, $prefix) = @_;

    return substr($string, 0, length($prefix)) eq $prefix;
}

sub is_gensym {
    my ($expr) = @_;

    return is_symbol($expr)
        && starts_with(symbol_name($expr), $GENSYM_PREFIX);
}

our @EXPORT_OK = qw(
    gensym
    is_gensym
);

1;
