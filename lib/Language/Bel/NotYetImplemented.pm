package Language::Bel::NotYetImplemented;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub list {
    return (
        printer => [
            "(function print)",
            "clo",
            "('unboundb print)",
        ],
    );
}

our @EXPORT_OK = qw(
    list
);

1;
