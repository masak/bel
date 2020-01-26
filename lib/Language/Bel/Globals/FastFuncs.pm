package Language::Bel::Globals::FastFuncs;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_nil
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
    SYMBOL_T
);

use Exporter 'import';

my %FASTFUNCS = (
    "no" => sub {
        my ($x) = @_;

        return is_nil($x) ? SYMBOL_T : SYMBOL_NIL;
    },
);

sub FASTFUNCS {
    return \%FASTFUNCS;
}

our @EXPORT_OK = qw(
    FASTFUNCS
);

1;
