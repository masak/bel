package Language::Bel::Printer;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    char_name
    is_char
    is_nil
    is_pair
    is_string
    is_symbol
    pair_car
    pair_cdr
    string_value
    symbol_name
);

use Exporter 'import';

sub _print {
    my ($ast) = @_;

    my $string_escape = sub {
        my ($string) = @_;

        return join("", map {
            $_ eq q["] || $_ eq q[\\] ? "\\$_" : $_
        } split("", $string));
    };

    if (is_symbol($ast)) {
        my $name = symbol_name($ast);
        return $name;
    }
    elsif (is_char($ast)) {
        my $name = char_name($ast);
        return "\\$name";
    }
    elsif (is_string($ast)) {
        my $string = string_value($ast);
        return q["] . $string_escape->($string) . q["];
    }
    elsif (is_pair($ast)) {
        my @fragments = ("(");
        my $first_elem = 1;
        while (is_pair($ast)) {
            if (!$first_elem) {
                push @fragments, " ";
            }
            push @fragments, _print(pair_car($ast));
            $ast = pair_cdr($ast);
            $first_elem = "";
        }
        if (!is_nil($ast)) {
            push @fragments, " . ";
            push @fragments, _print($ast);
        }
        push @fragments, ")";
        return join("", @fragments);
    }
    else {
        die "unhandled: not a symbol";
    }
}

our @EXPORT_OK = qw(
    _print
);

1;
