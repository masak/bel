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
    SYMBOL_CHAR
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
    fastfunc__no
    fastfunc__atom
    fastfunc__all
    fastfunc__some
    fastfunc__where__some
    fastfunc__reduce
    fastfunc__cons
    fastfunc__append
    fastfunc__snoc
    fastfunc__list
    fastfunc__map
    fastfunc__eq
    fastfunc__symbol
    fastfunc__pair
    fastfunc__char
    fastfunc__proper
    fastfunc__string
    fastfunc__mem
    fastfunc__where__mem
    fastfunc__in
    fastfunc__where__in
    fastfunc__cadr
    fastfunc__where__cadr
    fastfunc__cddr
    fastfunc__where__cddr
    fastfunc__caddr
    fastfunc__where__caddr
    fastfunc__find
    fastfunc__where__find
    fastfunc__begins
    fastfunc__caris
    fastfunc__hug
    fastfunc__keep
    fastfunc__rem
    fastfunc__get
    fastfunc__where__get
    fastfunc__put
    fastfunc__rev
    fastfunc__snap
    fastfunc__udrop
    fastfunc__idfn
    fastfunc__where__idfn
    fastfunc__pairwise
    fastfunc__foldl
    fastfunc__foldr
    fastfunc__fuse
    fastfunc__match
    fastfunc__split
    fastfunc__i_lt
    fastfunc__i_plus
    fastfunc__i_minus
    fastfunc__i_star
    fastfunc__i_slash
    fastfunc__i_hat
    fastfunc__r_plus
    fastfunc__r_minus
    fastfunc__r_star
    fastfunc__r_slash
    fastfunc__sr_plus
    fastfunc__sr_minus
    fastfunc__srinv
    fastfunc__sr_star
    fastfunc__sr_slash
    fastfunc__srrecip
    fastfunc__sr_lt
    fastfunc__srnum
    fastfunc__where__srnum
    fastfunc__srden
    fastfunc__where__srden
    fastfunc__c_plus
    fastfunc__c_star
    fastfunc__litnum
    fastfunc__number
    fastfunc__numr
    fastfunc__numi
    fastfunc__rpart
    fastfunc__ipart
    fastfunc__real
    fastfunc__prn
    fastfunc__pr
    fastfunc__prs
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
    my $mangled_name = $name;
    $mangled_name =~ s/^=/eq/;
    $mangled_name =~ s/\+/_plus/g;
    $mangled_name =~ s/-/_minus/g;
    $mangled_name =~ s/\*/_star/g;
    $mangled_name =~ s!/!_slash!g;
    $mangled_name =~ s/\^/_hat/g;
    $mangled_name =~ s/</_lt/g;
    my $maybe_ff_d = FASTFUNCS->{$name} && FASTFUNCS->{"where__$name"}
        ? "make_fastfunc($serialized, \\\&fastfunc__$mangled_name, \\\&fastfunc__where__$mangled_name)"
        : FASTFUNCS->{$name}
        ? "make_fastfunc($serialized, \\\&fastfunc__$mangled_name)"
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
