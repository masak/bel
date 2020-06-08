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
        streams => [
            "(function stream)",
            "clo",
            "('unboundb stream)",
        ],
        reader => [
            q[(read '("[cons _ 'b]"))],
            "(fn (_) (cons _ 'b))",
            "('unboundb read)",
        ],
        evaluator => [
            "(bel 'hi)",
            "hi",
            "('unboundb bel)",
        ],
    );
}

our @EXPORT_OK = qw(
    list
);

1;