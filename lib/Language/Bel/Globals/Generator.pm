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
    pairs_are_identical
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
);
use Language::Bel::Primitives;
use Language::Bel::Reader qw(
    read_whole
);
use Language::Bel::Expander::Bquote qw(
    _bqexpand
);
use Language::Bel::Globals::Source;
use Language::Bel::Globals::FastFuncs;
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

my %FASTFUNCS;
for my $name (@Language::Bel::Globals::FastFuncs::EXPORT_OK) {
    if ($name =~ /fastfunc__/) {
        $FASTFUNCS{$name} = 1;
    }
}

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
    my ($bel) = @_;

    print <<'HEADER';
package Language::Bel::Globals;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    are_identical
    is_symbol
    make_char
    make_pair
    make_symbol
    make_fastfunc
    pair_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_CHAR
    SYMBOL_NIL
    SYMBOL_PAIR
    SYMBOL_QUOTE
    SYMBOL_SYMBOL
    SYMBOL_T
);
use Language::Bel::Primitives;
use Language::Bel::Globals::FastFuncs qw(
HEADER

    for my $name (@Language::Bel::Globals::FastFuncs::EXPORT_OK) {
        if ($name =~ /fastfunc__/) {
            print " " x 4, $name, "\n";
        }
    }

    print <<'HEADER';
);

sub make_prim {
    my ($name) = @_;

    return make_pair(
        make_symbol("lit"),
        make_pair(
            make_symbol("prim"),
            make_pair(
                make_symbol($name),
                SYMBOL_NIL,
            ),
        ),
    );
}

sub add_global {
    my ($self, $name, $value) = @_;

    my $kv = make_pair(make_symbol($name), $value);

    $self->{hash_ref}->{$name} = $kv;
    $self->{list} = make_pair($kv, $self->{list});
}

sub new {
    my ($class, $options_ref) = @_;
    my $self = {
        ref($options_ref) eq "HASH" ? %$options_ref : (),
    };

    $self = bless($self, $class);
    if (!defined($self->{primitives})) {
        $self->{primitives} = Language::Bel::Primitives->new({ output => sub {} });
    }
    if (!defined($self->{hash_ref}) && !defined($self->{list})) {
        $self->{hash_ref} = {};
        $self->{list} = SYMBOL_NIL;

HEADER

    for my $prim_name (Language::Bel::Primitives->all_primitives()) {
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

        my $car_ast = $bel->car($ast);
        die "First element of list is not a symbol"
            unless is_symbol($car_ast);

        my $name = symbol_name($bel->car($bel->cdr($ast)));
        my $cddr_ast = $bel->cdr($bel->cdr($ast));
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
            while (!is_nil($bel->cdr($ast))) {
                $new_ast = $bel->car($cddr_ast);
                push @globals, {
                    name => $name,
                    expr => $bel->eval(_bqexpand($new_ast)),
                };

                $ast = $bel->cdr($bel->cdr($ast));
                $name = symbol_name($bel->car($bel->cdr($ast)));
                $cddr_ast = $bel->cdr($bel->cdr($ast));
            }
            next DECLARATION;
        }
        elsif (symbol_name($car_ast) eq "form") {
            my $name = $bel->car($bel->cdr($ast));
            my $parms = $bel->car($bel->cdr($bel->cdr($ast)));
            my $body = $bel->cdr($bel->cdr($bel->cdr($ast)));
            for my $global (@globals) {
                if ($global->{name} eq "forms") {
                    my $formfn = $bel->eval(
                        make_pair(
                            make_symbol("formfn"),
                            make_pair(
                                make_pair(
                                    make_symbol("quote"),
                                    make_pair(
                                        $parms,
                                        SYMBOL_NIL,
                                    ),
                                ),
                                make_pair(
                                    make_pair(
                                        make_symbol("quote"),
                                        make_pair(
                                            $body,
                                            SYMBOL_NIL,
                                        )
                                    ),
                                    SYMBOL_NIL,
                                ),
                            ),
                        ),
                    );
                    my $new_form = $bel->eval($formfn);
                    $global->{expr} = make_pair(
                        make_pair(
                            $name,
                            $new_form,
                        ),
                        $global->{expr},
                    );
                    last;
                }
            }
            next;
        }
        elsif (symbol_name($car_ast) eq "vir") {
            my $tag = $bel->car($bel->cdr($ast));
            my $rest = $bel->cdr($bel->cdr($ast));
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
            my $tag = $bel->eval($bel->car($bel->cdr($ast)));
            my $rest = $bel->cdr($bel->cdr($ast));
            for my $global (@globals) {
                if ($global->{name} eq "locfns") {
                    $global->{expr} = make_pair(
                        make_pair(
                            $tag,
                            make_pair(
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
                                SYMBOL_NIL,
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
            my $f = $bel->car($bel->cdr($ast));
            my $g = $bel->car($bel->cdr($bel->cdr($ast)));
            for my $global (@globals) {
                if ($global->{name} eq "comfns") {
                    $global->{expr} = make_pair(
                        make_pair(
                            $bel->eval($f),
                            $bel->eval($g),
                        ),
                        $global->{expr},
                    );
                    last;
                }
            }
            next;
        }
        elsif (symbol_name($car_ast) eq "syn") {
            my $c = $bel->car($bel->cdr($ast));
            my $rest = $bel->car($bel->cdr($bel->cdr($ast)));
            for my $global (@globals) {
                if ($global->{name} eq "syntax") {
                    $global->{expr} = make_pair(
                        make_pair(
                            $c,
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
        else {
            die "Unrecognized: $declaration";
        }

        push @globals, {
            name => $name,
            expr => $bel->eval(_bqexpand($new_ast)),
        };
    }

    my $vmark = $bel->eval(make_symbol("vmark"));
    my $smark = $bel->eval(make_symbol("smark"));
    my $first = 1;
    for my $global (@globals) {
        if ($first) {
            $first = 0;
        }
        else {
            print("\n");
        }

        print_global($global->{name}, $global->{expr}, $vmark, $smark);
    }

    print <<'FOOTER';
    }

    return $self;
}

sub get_kv {
    my ($self, $name) = @_;

    return $self->{hash_ref}->{$name};
}

sub is_global_of_name {
    my ($self, $e, $global_name) = @_;

    my $kv = $self->get_kv($global_name);
    my $global = pair_cdr($kv);
    return $global && are_identical($e, $global);
}

# (let cell (cons v nil)
#   (xdr g (cons cell (cdr g)))
#   cell)))
sub install {
    my ($self, $v) = @_;

    my $cell = make_pair($v, SYMBOL_NIL);
    if (is_symbol($v)) { # XXX: might be a uvar
        my $name = symbol_name($v);
        $self->{hash_ref}->{$name} = $cell;
    }
    my $prim = $self->{primitives};
    $prim->prim_xdr($self->{list}, make_pair(
        $cell,
        $prim->prim_cdr($self->{list}),
    ));

    return $cell;
}

sub list {
    my ($self) = @_;

    return $self->{list};
}

1;
FOOTER
}

my $ADD = q[$self->add_global];

sub print_primitive {
    my ($name) = @_;

    print(qq[        $ADD("$name", make_prim("$name"));\n\n]);
}

sub print_global {
    my ($name, $value, $vmark, $smark) = @_;

    my $uvars_ref = find_uvars($value, $vmark);
    for my $id (sort { $a <=> $b } values(%{$uvars_ref})) {
        print_uvar_decl($id);
    }

    my $serialized = serialize($value, $vmark, $smark, $uvars_ref);
    my $mangled_name = $name;
    $mangled_name =~ s/^=/eq/;
    $mangled_name =~ s/\+/_plus/g;
    $mangled_name =~ s/-/_minus/g;
    $mangled_name =~ s/\*/_star/g;
    $mangled_name =~ s!/!_slash!g;
    $mangled_name =~ s/\^/_hat/g;
    $mangled_name =~ s/</_lt/g;
    my $fastfunc_name = "fastfunc__$mangled_name";
    my $fastfunc_where_name = "fastfunc__where__$mangled_name";
    my $maybe_ff_d = $FASTFUNCS{$fastfunc_name} && $FASTFUNCS{$fastfunc_where_name}
        ? "make_fastfunc($serialized, \\\&$fastfunc_name, \\\&$fastfunc_where_name)"
        : $FASTFUNCS{$fastfunc_name}
        ? "make_fastfunc($serialized, \\\&$fastfunc_name)"
        : $serialized;
    my $formatted = break_lines(qq[$ADD("$name", $maybe_ff_d);]);
    my $indented = join("\n", map { "        $_" } split("\n", $formatted));
    print("$indented\n");
}

sub print_uvar_decl {
    my ($id) = @_;

    my $indent = " " x 8;
    my $vmark_value = 'pair_cdr($self->get_kv("vmark"))';
    my $uvar_value = qq[make_pair($vmark_value, SYMBOL_NIL)];
    print($indent, qq[my \$uvar_$id = $uvar_value;\n]);
}

my $uvar_next_unique_id = 1;

sub find_uvars {
    my ($value, $vmark, $uvars_ref) = @_;

    if (!defined($uvars_ref)) {
        $uvars_ref = {};
    }

    if (is_pair($value)) {
        my $car = pair_car($value);
        if (is_pair($car) && pairs_are_identical($car, $vmark)) {
            if (!exists $uvars_ref->{$value}) {
                $uvars_ref->{$value} = $uvar_next_unique_id++;
            }
        }
        else {
            find_uvars(pair_car($value), $vmark, $uvars_ref);
            find_uvars(pair_cdr($value), $vmark, $uvars_ref);
        }
    }

    return $uvars_ref;
}

sub serialize {
    my ($value, $vmark, $smark, $uvars_ref) = @_;

    if (is_pair($value)) {
        if (exists $uvars_ref->{$value}) {
            my $id = $uvars_ref->{$value};
            return q[$uvar_] . $id;
        }
        elsif (defined($vmark) && pairs_are_identical($value, $vmark)) {
            die "Found a bare `vmark` value";
        }
        elsif (defined($smark) && pairs_are_identical($value, $smark)) {
            return q[pair_cdr($self->get_kv("smark"))];
        }
        else {
            my $car = serialize(pair_car($value), $vmark, $smark, $uvars_ref);
            my $cdr = serialize(pair_cdr($value), $vmark, $smark, $uvars_ref);
            return "make_pair($car, $cdr)";
        }
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

    my $indented = join "\n", map { "    $_" } @lines;
    $indented =~ s/^    //;
    return $indented;
}

our @EXPORT_OK = qw(
    generate_globals
);

1;
