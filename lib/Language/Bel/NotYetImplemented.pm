package Language::Bel::NotYetImplemented;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub list {
    return (
        chars => [
            "(nchar 65)",
            "\\A",
            "('unboundb nchar)",
        ],
        ccc => [
            "(list 'a (ccc (fn (c) 'b)))",
            "(a b)",
            "('unboundb ccc)",
        ],
        threads => [
            "(thread (+ 2 2))",
            "4",
            "('unboundb thread)",
        ],
        backquotes => [
            "(isa!mac bquote)",
            "t",
            "('unboundb bquote)",
        ],
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
