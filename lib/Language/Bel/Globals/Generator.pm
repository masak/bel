package Language::Bel::Globals::Generator;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_nil
    is_pair
    is_symbol
    is_symbol_of_name
    make_pair
    make_symbol
    pair_car
    pair_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
    SYMBOL_PAIR
    SYMBOL_QUOTE
    SYMBOL_SYMBOL
    SYMBOL_T
);
use Language::Bel::Primitives qw(
    PRIMITIVES
);
use Language::Bel::Primitives qw(
    prim_car
    prim_cdr
    PRIM_FN
);
use Language::Bel::Reader qw(
    _read
);
use Language::Bel::Expander::Bquote qw(
    _bqexpand
);
use Language::Bel::Globals::Source;
use Language::Bel::Interpreter;

use Exporter 'import';

my %KNOWN_SYMBOL = qw(
    char        1
    nil         1
    pair        1
    quote       1
    symbol      1
    t           1
);

my @DECLARATIONS;
{
    my $para = "";
    my $add_declaration = sub {
        $para =~ s/\s+$//;
        push @DECLARATIONS, $para;
        $para = "";
    };
    my $accumulate_line = sub {
        my ($line) = @_;

        $para .= $line;
    };
    while (<Language::Bel::Globals::Source::DATA>) {
        s/^\s+//;
        if ($_ eq "") {
            $add_declaration->();
        }
        else {
            $accumulate_line->($_);
        }
    }
    if ($para ne "") {
        $add_declaration->();
    }
}

sub generate_globals {
    my ($interpreter) = @_;

    print <<'HEADER';
package Language::Bel::Globals;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    make_pair
    make_symbol
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_CHAR
    SYMBOL_NIL
    SYMBOL_PAIR
    SYMBOL_QUOTE
    SYMBOL_SYMBOL
    SYMBOL_T
);
use Language::Bel::Primitives qw(
    PRIM_FN
);

use Exporter 'import';

my %globals;

sub GLOBALS {
    return \%globals;
}

HEADER

    for my $prim_name (keys(%{PRIMITIVES()})) {
        print_global($prim_name, PRIMITIVES->{$prim_name});
    }

    DECLARATION:
    for my $declaration (@DECLARATIONS) {
        my $ast = _read($declaration);
        next
            if is_nil($ast);   # `;` comment
        die "Malformed global declaration\n"
            unless is_pair($ast);

        my $car_ast = prim_car($ast);
        die "First element of list is not a symbol"
            unless is_symbol($car_ast);

        my $name = symbol_name(prim_car(prim_cdr($ast)));
        my $cddr_ast = prim_cdr(prim_cdr($ast));
        my $new_ast;

        if (symbol_name($car_ast) eq "def") {
            # (From bellanguage.txt)
            #
            # In the source I try not to use things before I've defined
            # them, but I've made a handful of exceptions to make the code
            # easier to read.
            #
            # When you see
            #
            # (def n p e)
            #
            # treat it as an abbreviation for
            #
            # (set n (lit clo nil p e))

            $new_ast = make_pair(
                make_symbol("lit"),
                make_pair(
                    make_symbol("clo"),
                    make_pair(
                        SYMBOL_NIL,
                        $cddr_ast,
                    ),
                ),
            );
        }
        elsif (symbol_name($car_ast) eq "mac") {
            # and when you see
            #
            # (mac n p e)
            #
            # treat it as an abbreviation for
            #
            # (set n (lit mac (lit clo nil p e)))

            $new_ast = make_pair(
                make_symbol("lit"),
                make_pair(
                    make_symbol("mac"),
                    make_pair(
                        make_pair(
                            make_symbol("lit"),
                            make_pair(
                                make_symbol("clo"),
                                make_pair(
                                    SYMBOL_NIL,
                                    $cddr_ast,
                                ),
                            ),
                        ),
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
        elsif (symbol_name($car_ast) eq "set") {
            while (!is_nil(prim_cdr($ast))) {
                $new_ast = prim_car($cddr_ast);
                print_global($name, $interpreter->eval_ast(_bqexpand($new_ast)));

                $ast = prim_cdr(prim_cdr($ast));
                $name = symbol_name(prim_car(prim_cdr($ast)));
                $cddr_ast = prim_cdr(prim_cdr($ast));
            }
            next DECLARATION;
        }
        else {
            die "Unrecognized: $declaration";
        }

        print_global($name, $interpreter->eval_ast(_bqexpand($new_ast)));
    }

    print <<'FOOTER';

our @EXPORT_OK = qw(
    GLOBALS
);

1;
FOOTER
}

sub print_global {
    my ($name, $value) = @_;

    print('$globals{"', $name, '"} =', "\n");
    print(indent(serialize($value)), ";\n");
    print("\n");
}

sub serialize {
    my ($value) = @_;

    if (is_pair($value)) {
        my $car = serialize(pair_car($value));
        my $cdr = serialize(pair_cdr($value));
        return join("",
            "make_pair(\n",
            indent($car),
            ",\n",
            indent($cdr),
            ")",
        );
    }
    elsif (is_symbol($value)) {
        my $name = symbol_name($value);
        return $KNOWN_SYMBOL{$name}
            ? "SYMBOL_" . uc($name)
            : qq[make_symbol("$name")];
    }
    else {
        die "Unknown value: ", ref($value), "\n";
    }
}

sub indent {
    my ($string) = @_;

    return join "\n", map { (" " x 4) . $_ } split "\n", $string;
}

our @EXPORT_OK = qw(
    generate_globals
);

1;
