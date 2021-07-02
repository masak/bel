package Language::Bel::Bytecode;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub PARAM_IN { 0x00 }
sub PARAM_NEXT { 0x01 }
sub SET_PARAM_NEXT { 0x02 }
sub PARAM_LAST { 0x03 }
sub PARAM_OUT { 0x04 }

sub SET_PRIM_ID_REG_SYM { 0x10 }
sub SET_PRIM_TYPE_REG { 0x11 }

sub RETURN_REG { 0xF0 }

my @registered_symbols = (
    "nil",
    "t",
    "pair",
);

my %index_of;
my $index = 0;
for my $name (@registered_symbols) {
    $index_of{$name} = $index;
    ++$index;
}

sub SYMBOL {
    my ($name) = @_;

    die "Unknown symbo `$name`"
        unless defined $index_of{$name};

    return $index_of{$name};
}

sub n { 0 }

our @EXPORT_OK = qw(
    n
    PARAM_IN
    PARAM_LAST
    PARAM_NEXT
    PARAM_OUT
    RETURN_REG
    SET_PARAM_NEXT
    SET_PRIM_ID_REG_SYM
    SET_PRIM_TYPE_REG
    SYMBOL
);

1;
