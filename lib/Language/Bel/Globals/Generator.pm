package Language::Bel::Globals::Generator;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    char_codepoint
    is_char
    is_nil
    is_pair
    is_symbol
    make_fastfunc
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
);
use Language::Bel::Reader qw(
    read_whole
);
use Language::Bel::Expander::Bquote qw(
    _bqexpand
);
use Language::Bel::Globals::Source;
use Language::Bel::Globals::FastFuncs qw(
    FASTFUNCS
);
use Language::Bel;

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
    make_char
    make_pair
    make_symbol
    make_fastfunc
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
use Language::Bel::Globals::FastFuncs qw(
    FASTFUNCS
);

use Exporter 'import';

my %globals;

sub GLOBALS {
    return \%globals;
}

HEADER

    for my $prim_name (sort(keys(%{PRIMITIVES()}))) {
        print_primitive($prim_name);
    }

    my @globals;

    DECLARATION:
    for my $declaration (@DECLARATIONS) {
        my $ast = read_whole($declaration);
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

            # [masak] Yes, but then it also says, "The actual def and mac
            # operators are more powerful, but this is as much as we need
            # to start with." The place where it falls down, it turns out,
            # is the definition of `enq`, the first function to use the
            # implicit `do` semantics of `def`. In that case, (just as with
            # the real `def`), we wrap `e` in a `do`.
            my $params = pair_car($cddr_ast);
            my $rest = pair_cdr($cddr_ast);
            my $body = is_nil($rest)
                ? SYMBOL_NIL
                : is_nil(pair_cdr($rest))
                    ? pair_car($rest)
                    : make_pair(
                        make_symbol("do"),
                        $rest,
                    );

            $new_ast = make_pair(
                make_symbol("lit"),
                make_pair(
                    make_symbol("clo"),
                    make_pair(
                        SYMBOL_NIL,
                        make_pair(
                            $params,
                            make_pair(
                                $body,
                                SYMBOL_NIL,
                            )
                        ),
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
                push @globals, {
                    name => $name,
                    expr => $interpreter->eval_ast(_bqexpand($new_ast)),
                };

                $ast = prim_cdr(prim_cdr($ast));
                $name = symbol_name(prim_car(prim_cdr($ast)));
                $cddr_ast = prim_cdr(prim_cdr($ast));
            }
            next DECLARATION;
        }
        elsif (symbol_name($car_ast) eq "vir") {
            my $tag = prim_car(prim_cdr($ast));
            my $rest = prim_cdr(prim_cdr($ast));
            for my $global (@globals) {
                if ($global->{name} eq "virfns") {
                    $global->{expr} = make_pair(
                        make_pair(
                            $tag,
                            make_pair(
                                make_symbol("lit"),
                                make_pair(
                                    make_symbol("clo"),
                                    make_pair(
                                        SYMBOL_NIL,
                                        _bqexpand($rest),
                                    ),
                                ),
                            ),
                        ),
                        $global->{expr},
                    );
                    last;
                }
            }
            next;
        }
        elsif (symbol_name($car_ast) eq "loc") {
            my $tag = prim_car(prim_cdr($ast));
            my $rest = prim_cdr(prim_cdr($ast));
            for my $global (@globals) {
                if ($global->{name} eq "locfns") {
                    $global->{expr} = make_pair(
                        make_pair(
                            $tag,
                            make_pair(
                                make_symbol("lit"),
                                make_pair(
                                    make_symbol("clo"),
                                    make_pair(
                                        SYMBOL_NIL,
                                        _bqexpand($rest),
                                    ),
                                ),
                            ),
                        ),
                        $global->{expr},
                    );
                    last;
                }
            }
            next;
        }
        elsif (symbol_name($car_ast) eq "com") {
            my $f = prim_car(prim_cdr($ast));
            my $g = prim_car(prim_cdr(prim_cdr($ast)));
            for my $global (@globals) {
                if ($global->{name} eq "comfns") {
                    $global->{expr} = make_pair(
                        make_pair(
                            $interpreter->eval_ast($f),
                            $interpreter->eval_ast($g),
                        ),
                        $global->{expr},
                    );
                    last;
                }
            }
            next;
        }
        else {
            die "Unrecognized: $declaration";
        }

        push @globals, {
            name => $name,
            expr => $interpreter->eval_ast(_bqexpand($new_ast)),
        };
    }

    for my $global (@globals) {
        print_global($global->{name}, $global->{expr});
    }

    print <<'FOOTER';
our @EXPORT_OK = qw(
    GLOBALS
);

1;
FOOTER
}

sub print_primitive {
    my ($name) = @_;

    print('$globals{"', $name, '"} = PRIMITIVES->{"', $name, '"};', "\n");
    print("\n");
}

sub print_global {
    my ($name, $value) = @_;

    my $serialized = serialize($value);
    my $maybe_ff_d = FASTFUNCS->{$name} && FASTFUNCS->{"where__$name"}
        ? "make_fastfunc($serialized, FASTFUNCS->{'$name'}, FASTFUNCS->{'where__$name'})"
        : FASTFUNCS->{$name}
        ? "make_fastfunc($serialized, FASTFUNCS->{'$name'})"
        : $serialized;
    my $formatted = break_lines($maybe_ff_d);
    print('$globals{"', $name, '"} =', "\n");
    print("$formatted;\n");
    print("\n");
}

sub serialize {
    my ($value) = @_;

    if (is_pair($value)) {
        my $car = serialize(pair_car($value));
        my $cdr = serialize(pair_cdr($value));
        return "make_pair($car, $cdr)";
    }
    elsif (is_symbol($value)) {
        my $name = symbol_name($value);
        return $KNOWN_SYMBOL{$name}
            ? "SYMBOL_" . uc($name)
            : qq[make_symbol("$name")];
    }
    elsif (is_char($value)) {
        my $codepoint = char_codepoint($value);
        return qq[make_char($codepoint)];
    }
    else {
        die "Unknown value: ", ref($value), "\n";
    }
}

sub break_lines {
    my ($text) = @_;

    my $MAX_LINE_LENGTH = 72;
    my @lines;
    while (length($text) > $MAX_LINE_LENGTH) {
        my $break_pos = $MAX_LINE_LENGTH;
        while (substr($text, $break_pos, 1) ne " ") {
            --$break_pos;
            if ($break_pos < 0) {
                die "Didn't find a single space in the whole line to break";
            }
        }
        push @lines, substr($text, 0, $break_pos);
        $text = substr($text, $break_pos + 1);
    }
    push @lines, $text;

    return join "\n", map { "    $_" } @lines;
}

our @EXPORT_OK = qw(
    generate_globals
);

1;
