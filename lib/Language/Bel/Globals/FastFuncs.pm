package Language::Bel::Globals::FastFuncs;

use 5.006;
use strict;
use warnings;

use Language::Bel::AsyncCall qw(
    make_async_call
);
use Language::Bel::Core qw(
    are_identical
    atoms_are_identical
    char_codepoint
    is_char
    is_nil
    is_pair
    is_stream
    is_symbol
    is_symbol_of_name
    make_char
    make_pair
    make_symbol
    SYMBOL_A
    SYMBOL_D
    SYMBOL_NIL
    SYMBOL_T
);
use Language::Bel::Pair::Num qw(
    make_num
    maybe_get_int
);
use Language::Bel::Pair::Str qw(
    is_str
    make_str
);
use Language::Bel::Pair::SignedRat qw(
    make_signed_rat
);
use Language::Bel::Primitives;
use Language::Bel::Printer qw(
    _print
);

use Exporter 'import';

sub fastfunc__no {
    my ($bel, $x) = @_;

    return is_nil($x) ? SYMBOL_T : SYMBOL_NIL;
}

sub fastfunc__atom {
    my ($bel, $x) = @_;

    return is_pair($x) ? SYMBOL_NIL : SYMBOL_T;
}

sub fastfunc__all {
    my ($bel, $f, $xs) = @_;

    my $loop;
    $loop = sub {
        while (!is_nil($xs)) {
            return make_async_call(
                $f,
                [$bel->car($xs)],
                sub {
                    my ($result) = @_;
                    if (is_nil($result)) {
                        return SYMBOL_NIL;
                    }
                    $xs = $bel->cdr($xs);
                    return $loop->();
                },
            );
        }

        return SYMBOL_T;
    };

    return $loop->();
}

sub fastfunc__some {
    my ($bel, $f, $xs) = @_;

    my $loop;
    $loop = sub {
        while (!is_nil($xs)) {
            return make_async_call(
                $f,
                [$bel->car($xs)],
                sub {
                    my ($result) = @_;
                    if (!is_nil($result)) {
                        return $xs;
                    }
                    $xs = $bel->cdr($xs);
                    return $loop->();
                },
            );
        }

        return SYMBOL_NIL;
    };

    return $loop->();
}

sub fastfunc__where__some {
    my ($bel, $f, $xs) = @_;

    my $loop;
    $loop = sub {
        while (!is_nil($xs)) {
            return make_async_call(
                $f,
                [$bel->car($xs)],
                sub {
                    my ($result) = @_;
                    if (!is_nil($result)) {
                        return make_pair(
                            make_pair(
                                make_symbol("xs"),
                                $xs,
                            ),
                            make_pair(
                                SYMBOL_D,
                                SYMBOL_NIL,
                            ),
                        );

                    }
                    $xs = $bel->cdr($xs);
                    return $loop->();
                },
            );
        }

        return SYMBOL_NIL;
    };

    return $loop->();
}

sub fastfunc__reduce {
    my ($bel, $f, $xs) = @_;

    my @values;
    while (!is_nil($xs)) {
        push @values, $bel->car($xs);
        $xs = $bel->cdr($xs);
    }

    my $loop;
    $loop = sub {
        my ($result) = @_;

        while (@values) {
            my $value = pop(@values);
            return make_async_call(
                $f,
                [$value, $result],
                $loop,      # yup; eta-reduced
            );
        }

        return $result;
    };

    $loop->(@values ? pop(@values) : SYMBOL_NIL);
}

sub fastfunc__cons {
    my ($bel, @args) = @_;

    my $result = @args ? pop(@args) : SYMBOL_NIL;
    while (@args) {
        my $value = pop(@args);
        $result = make_pair($value, $result);
    }

    return $result;
}

sub fastfunc__append {
    my ($bel, @args) = @_;

    my $result = @args ? pop(@args) : SYMBOL_NIL;
    while (@args) {
        my $list = pop(@args);
        my @values;
        while (!is_nil($list)) {
            push @values, $bel->car($list);
            $list = $bel->cdr($list);
        }
        while (@values) {
            my $value = pop(@values);
            $result = make_pair($value, $result);
        }
    }

    return $result;
}

sub fastfunc__snoc {
    my ($bel, @args) = @_;

    my $result = SYMBOL_NIL;
    while (scalar(@args) > 1) {
        my $value = pop(@args);
        $result = make_pair($value, $result);
    }
    if (@args) {
        my $list = pop(@args);
        my @values;
        while (!is_nil($list)) {
            push @values, $bel->car($list);
            $list = $bel->cdr($list);
        }
        while (@values) {
            my $value = pop(@values);
            $result = make_pair($value, $result);
        }
    }

    return $result;
}

sub fastfunc__list {
    my ($bel, @args) = @_;

    my $result = SYMBOL_NIL;
    while (@args) {
        my $value = pop(@args);
        $result = make_pair($value, $result);
    }

    return $result;
}

sub fastfunc__map {
    my ($bel, $f, @ls) = @_;

    return SYMBOL_NIL
        unless @ls;

    my @result;

    my $loop1;
    my $after_loop1;

    $loop1 = sub {
        my @arguments;

        my $loop2;
        $loop2 = sub {
            my ($i) = @_;

            if ($i < @ls) {
                my $list = $ls[$i];
                return $after_loop1->()
                    if is_nil($list);

                push @arguments, $bel->car($list);
                $ls[$i] = $bel->cdr($list);

                return $loop2->($i + 1);
            }
            else {
                return make_async_call(
                    $f,
                    [@arguments],
                    sub {
                        my ($result) = @_;
                        push @result, $result;
                        $loop1->();
                    },
                );
            }
        };

        return $loop2->(0);
    };

    $after_loop1 = sub {
        my $result = SYMBOL_NIL;
        for my $v (reverse(@result)) {
            $result = make_pair($v, $result);
        }

        return $result;
    };

    return $loop1->();
}

sub fastfunc__eq  {
    my ($bel, @args) = @_;

    my @stack = [@args];
    while (@stack) {
        my @values = @{pop(@stack)};
        next unless @values;
        my $some_atom = "";
        for my $value (@values) {
            if (!is_pair($value)) {
                $some_atom = 1;
                last;
            }
        }
        if ($some_atom) {
            my $car_values = $values[0];
            for my $value (@values) {
                if (!atoms_are_identical($value, $car_values)) {
                    return SYMBOL_NIL;
                }
            }
        }
        else {
            push @stack, [map { $bel->cdr($_) } @values];
            push @stack, [map { $bel->car($_) } @values];
        }
    }

    return SYMBOL_T;
}

sub fastfunc__symbol {
    my ($bel, $x) = @_;

    return is_symbol($x) ? SYMBOL_T : SYMBOL_NIL;
}

sub fastfunc__pair {
    my ($bel, $x) = @_;

    return is_pair($x) ? SYMBOL_T : SYMBOL_NIL;
}

sub fastfunc__char {
    my ($bel, $x) = @_;

    return is_char($x) ? SYMBOL_T : SYMBOL_NIL;
}

sub fastfunc__stream {
    my ($bel, $x) = @_;

    return is_stream($x) ? SYMBOL_T : SYMBOL_NIL;
}

sub fastfunc__proper {
    my ($bel, $x) = @_;

    while (!is_nil($x)) {
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }
        $x = $bel->cdr($x);
    }

    return SYMBOL_T;
}

sub fastfunc__string {
    my ($bel, $x) = @_;

    if (is_str($x)) {
        return SYMBOL_T;
    }
    while (!is_nil($x)) {
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }
        if (!is_char($bel->car($x))) {
            return SYMBOL_NIL;
        }
        $x = $bel->cdr($x);
    }

    return SYMBOL_T;
}

sub fastfunc__mem {
    my ($bel, $x, $ys, $f) = @_;

    if (defined($f)) {
        my $loop;
        $loop = sub {
            return SYMBOL_NIL
                if is_nil($ys);

            return make_async_call(
                $f,
                [$bel->car($ys), $x],
                sub {
                    my ($p) = @_;
                    if (!is_nil($p)) {
                        return $ys;
                    }
                    $ys = $bel->cdr($ys);
                    return $loop->();
                },
            );
        };

        return $loop->();
    }
    else {
        ELEMENT:
        while (!is_nil($ys)) {
            my @stack = [$bel->car($ys), $x];
            while (@stack) {
                my @values = @{pop(@stack)};
                next unless @values;
                my $some_atom = "";
                for my $value (@values) {
                    if (!is_pair($value)) {
                        $some_atom = 1;
                        last;
                    }
                }
                if ($some_atom) {
                    my $car_values = $values[0];
                    for my $value (@values) {
                        if (!atoms_are_identical($value, $car_values)) {
                            $ys = $bel->cdr($ys);
                            next ELEMENT;
                        }
                    }
                }
                else {
                    push @stack, [map { $bel->cdr($_) } @values];
                    push @stack, [map { $bel->car($_) } @values];
                }
            }

            return $ys;
        }

        return SYMBOL_NIL;
    }
}

sub fastfunc__where__mem {
    my ($bel, $x, $ys, $f) = @_;

    if (defined($f)) {
        my $loop;
        $loop = sub {
            return SYMBOL_NIL
                if is_nil($ys);

            return make_async_call(
                $f,
                [$bel->car($ys), $x],
                sub {
                    my ($p) = @_;
                    if (!is_nil($p)) {
                        return make_pair(
                            make_pair(
                                make_symbol("xs"),
                                $ys,
                            ),
                            make_pair(
                                SYMBOL_D,
                                SYMBOL_NIL,
                            ),
                        );
                    }
                    $ys = $bel->cdr($ys);
                    return $loop->();
                },
            );
        };

        return $loop->();
    }
    else {
        ELEMENT:
        while (!is_nil($ys)) {
            my @stack = [$bel->car($ys), $x];
            while (@stack) {
                my @values = @{pop(@stack)};
                next unless @values;
                my $some_atom = "";
                for my $value (@values) {
                    if (!is_pair($value)) {
                        $some_atom = 1;
                        last;
                    }
                }
                if ($some_atom) {
                    my $car_values = $values[0];
                    for my $value (@values) {
                        if (!atoms_are_identical($value, $car_values)) {
                            $ys = $bel->cdr($ys);
                            next ELEMENT;
                        }
                    }
                }
                else {
                    push @stack, [map { $bel->cdr($_) } @values];
                    push @stack, [map { $bel->car($_) } @values];
                }
            }

            return make_pair(
                make_pair(
                    make_symbol("xs"),
                    $ys,
                ),
                make_pair(
                    SYMBOL_D,
                    SYMBOL_NIL,
                ),
            );
        }

        return SYMBOL_NIL;
    }
}

sub fastfunc__in {
    my ($bel, @args) = @_;

    my $x = @args ? shift(@args) : SYMBOL_NIL;

    ARG:
    while (@args) {
        my @stack = [$args[0], $x];
        while (@stack) {
            my @values = @{pop(@stack)};
            next unless @values;
            my $some_atom = "";
            for my $value (@values) {
                if (!is_pair($value)) {
                    $some_atom = 1;
                    last;
                }
            }
            if ($some_atom) {
                my $car_values = $values[0];
                for my $value (@values) {
                    if (!atoms_are_identical($value, $car_values)) {
                        shift(@args);
                        next ARG;
                    }
                }
            }
            else {
                push @stack, [map { $bel->cdr($_) } @values];
                push @stack, [map { $bel->car($_) } @values];
            }
        }
        last ARG;
    }

    my $ys = SYMBOL_NIL;
    while (@args) {
        $ys = make_pair(pop(@args), $ys);
    }
    return $ys;
}

sub fastfunc__where__in {
    my ($bel, @args) = @_;

    my $x = @args ? shift(@args) : SYMBOL_NIL;

    ARG:
    while (@args) {
        my @stack = [$args[0], $x];
        while (@stack) {
            my @values = @{pop(@stack)};
            next unless @values;
            my $some_atom = "";
            for my $value (@values) {
                if (!is_pair($value)) {
                    $some_atom = 1;
                    last;
                }
            }
            if ($some_atom) {
                my $car_values = $values[0];
                for my $value (@values) {
                    if (!atoms_are_identical($value, $car_values)) {
                        shift(@args);
                        next ARG;
                    }
                }
            }
            else {
                push @stack, [map { $bel->cdr($_) } @values];
                push @stack, [map { $bel->car($_) } @values];
            }
        }
        last ARG;
    }

    my $ys = SYMBOL_NIL;
    while (@args) {
        $ys = make_pair(pop(@args), $ys);
    }
    return is_nil($ys) ? $ys : (
        make_pair(
            make_pair(make_symbol("xs"), $ys),
            make_pair(SYMBOL_D, SYMBOL_NIL),
        )
    );
}

sub fastfunc__cadr {
    my ($bel, $x) = @_;

    return $bel->car($bel->cdr($x));
}

sub fastfunc__where__cadr {
    my ($bel, $x) = @_;

    return make_pair(
        $bel->cdr($x),
        make_pair(
            SYMBOL_A,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__cddr {
    my ($bel, $x) = @_;

    return $bel->cdr($bel->cdr($x));
}

sub fastfunc__where__cddr {
    my ($bel, $x) = @_;

    return make_pair(
        $bel->cdr($x),
        make_pair(
            SYMBOL_D,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__caddr {
    my ($bel, $x) = @_;

    return $bel->car($bel->cdr($bel->cdr($x)));
}

sub fastfunc__where__caddr {
    my ($bel, $x) = @_;

    return make_pair(
        $bel->cdr($bel->cdr($x)),
        make_pair(
            SYMBOL_A,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__find {
    my ($bel, $f, $xs) = @_;

    my $loop;
    $loop = sub {
        while (!is_nil($xs)) {
            my $value = $bel->car($xs);
            return make_async_call(
                $f,
                [$value],
                sub {
                    my ($p) = @_;
                    if (!is_nil($p)) {
                        return $value;
                    }
                    $xs = $bel->cdr($xs);
                    return $loop->();
                },
            );
        }
        return SYMBOL_NIL;
    };

    $loop->();
}

sub fastfunc__where__find {
    my ($bel, $f, $xs) = @_;

    my $loop;
    $loop = sub {
        while (!is_nil($xs)) {
            my $value = $bel->car($xs);
            return make_async_call(
                $f,
                [$value],
                sub {
                    my ($p) = @_;
                    if (!is_nil($p)) {
                        return make_pair(
                            $xs,
                            make_pair(
                                SYMBOL_A,
                                SYMBOL_NIL,
                            ),
                        );
                    }
                    $xs = $bel->cdr($xs);
                    return $loop->();
                },
            );
        }
        return SYMBOL_NIL;
    };

    $loop->();
}

sub fastfunc__begins {
    my ($bel, $xs, $pat, $f) = @_;

    if (defined($f)) {
        my $loop;
        $loop = sub {
            while (!is_nil($pat)) {
                if (!is_pair($xs)) {
                    return SYMBOL_NIL;
                }
                else {
                    return make_async_call(
                        $f,
                        [$bel->car($xs), $bel->car($pat)],
                        sub {
                            my ($p) = @_;
                            if (is_nil($p)) {
                                return SYMBOL_NIL;
                            }
                            $xs = $bel->cdr($xs);
                            $pat = $bel->cdr($pat);
                            return $loop->();
                        },
                    );
                }
            }

            return SYMBOL_T;
        };

        return $loop->();
    }
    else {
        while (!is_nil($pat)) {
            if (!is_pair($xs)) {
                return SYMBOL_NIL;
            }

            my @stack = [$bel->car($xs), $bel->car($pat)];
            while (@stack) {
                my @values = @{pop(@stack)};
                next unless @values;
                my $some_atom = "";
                for my $value (@values) {
                    if (!is_pair($value)) {
                        $some_atom = 1;
                        last;
                    }
                }
                if ($some_atom) {
                    my $car_values = $values[0];
                    for my $value (@values) {
                        if (!atoms_are_identical($value, $car_values)) {
                            return SYMBOL_NIL;
                        }
                    }
                }
                else {
                    push @stack, [map { $bel->cdr($_) } @values];
                    push @stack, [map { $bel->car($_) } @values];
                }
            }

            $xs = $bel->cdr($xs);
            $pat = $bel->cdr($pat);
        }

        return SYMBOL_T;
    }
}

sub fastfunc__caris {
    my ($bel, $x, $y, $f) = @_;

    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (defined($f)) {
        return make_async_call(
            $f,
            [$bel->car($x), $y],
            sub {
                my ($p) = @_;
                return $p;
            },
        );
    }
    else {
        my @stack = [$bel->car($x), $y];
        while (@stack) {
            my @values = @{pop(@stack)};
            next unless @values;
            my $some_atom = "";
            for my $value (@values) {
                if (!is_pair($value)) {
                    $some_atom = 1;
                    last;
                }
            }
            if ($some_atom) {
                my $car_values = $values[0];
                for my $value (@values) {
                    if (!atoms_are_identical($value, $car_values)) {
                        return SYMBOL_NIL;
                    }
                }
            }
            else {
                push @stack, [map { $bel->cdr($_) } @values];
                push @stack, [map { $bel->car($_) } @values];
            }
        }

        return SYMBOL_T;
    }
}

sub fastfunc__hug {
    my ($bel, $xs, $f) = @_;

    my @values;
    my $cdr_xs;
    if (defined($f)) {
        my $loop;
        my $after_loop;
        my $after_even_that;

        $loop = sub {
            while (!is_nil($cdr_xs = $bel->cdr($xs))) {
                return make_async_call(
                    $f,
                    [$bel->car($xs), $bel->car($cdr_xs)],
                    sub {
                        my ($value) = @_;
                        push @values, $value;
                        $xs = $bel->cdr($cdr_xs);
                        $loop->();
                    },
                );
            }

            return $after_loop->();
        };

        $after_loop = sub {
            if (!is_nil($xs)) {
                return make_async_call(
                    $f,
                    [$bel->car($xs)],
                    sub {
                        my ($result) = @_;
                        push @values, $result;
                        return $after_even_that->();
                    },
                );
            }
            else {
                return $after_even_that->();
            }
        };

        $after_even_that = sub {
            my $result = SYMBOL_NIL;
            for my $value (reverse(@values)) {
                $result = make_pair($value, $result);
            }
            return $result;
        };

        $loop->();
    }
    else {
        while (!is_nil($cdr_xs = $bel->cdr($xs))) {
            push @values, make_pair(
                $bel->car($xs),
                make_pair(
                    $bel->car($cdr_xs),
                    SYMBOL_NIL));
            $xs = $bel->cdr($cdr_xs);
        }
        if (!is_nil($xs)) {
            push @values, make_pair($bel->car($xs), SYMBOL_NIL);
        }

        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    }
}

sub fastfunc__keep {
    my ($bel, $f, $xs) = @_;

    my @values;
    my $loop;
    my $after_loop;

    $loop = sub {
        while (!is_nil($xs)) {
            my $value = $bel->car($xs);
            return make_async_call(
                $f,
                [$value],
                sub {
                    my ($result) = @_;
                    if (!is_nil($result)) {
                        push @values, $value;
                    }
                    $xs = $bel->cdr($xs);
                    $loop->();
                },
            );
        }

        $after_loop->();
    };

    $after_loop = sub {
        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    };

    $loop->();
}

sub fastfunc__rem {
    my ($bel, $x, $ys, $f) = @_;

    my @values;
    if (defined($f)) {
        my $loop;
        my $after_loop;

        $loop = sub {
            while (!is_nil($ys)) {
                my $value = $bel->car($ys);
                return make_async_call(
                    $f,
                    [$value, $x],
                    sub {
                        my ($p) = @_;
                        if (is_nil($p)) {
                            push @values, $value;
                        }
                        $ys = $bel->cdr($ys);
                        return $loop->();
                    },
                );
            }

            return $after_loop->();
        };

        $after_loop = sub {
            my $result = SYMBOL_NIL;
            for my $value (reverse(@values)) {
                $result = make_pair($value, $result);
            }
            return $result;
        };

        $loop->();
    }
    else {
        while (!is_nil($ys)) {
            my $value = $bel->car($ys);
            my @stack = [$x, $value];
            while (@stack) {
                my ($v0, $v1) = @{pop(@stack)};
                if (!is_pair($v0) || !is_pair($v1)) {
                    if (!atoms_are_identical($v0, $v1)) {
                        push @values, $value;
                        last;
                    }
                }
                else {
                    push @stack, [$bel->cdr($v0), $bel->cdr($v1)];
                    push @stack, [$bel->car($v0), $bel->car($v1)];
                }
            }
            $ys = $bel->cdr($ys);
        }

        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    }
}

sub fastfunc__get {
    my ($bel, $k, $kvs, $f) = @_;

    if (defined($f)) {
        my $loop;
        $loop = sub {
            while (!is_nil($kvs)) {
                my $kv = $bel->car($kvs);
                return make_async_call(
                    $f,
                    [$bel->car($kv), $k],
                    sub {
                        my ($p) = @_;
                        if (!is_nil($p)) {
                            return $kv;
                        }
                        $kvs = $bel->cdr($kvs);
                        return $loop->();
                    },
                );
            }

            return SYMBOL_NIL;
        };

        $loop->();
    }
    else {
        ELEM:
        while (!is_nil($kvs)) {
            my $kv = $bel->car($kvs);
            my @stack = [$bel->car($kv), $k];
            while (@stack) {
                my ($v0, $v1) = @{pop(@stack)};
                if (!is_pair($v0) || !is_pair($v1)) {
                    if (!atoms_are_identical($v0, $v1)) {
                        $kvs = $bel->cdr($kvs);
                        next ELEM;
                    }
                }
                else {
                    push @stack, [$bel->cdr($v0), $bel->cdr($v1)];
                    push @stack, [$bel->car($v0), $bel->car($v1)];
                }
            }
            return $kv;
        }

        return SYMBOL_NIL;
    }
}

sub fastfunc__where__get {
    my ($bel, $k, $kvs, $f) = @_;

    if (defined($f)) {
        my $loop;
        $loop = sub {
            while (!is_nil($kvs)) {
                my $kv = $bel->car($kvs);
                return make_async_call(
                    $f,
                    [$bel->car($kv), $k],
                    sub {
                        my ($p) = @_;
                        if (!is_nil($p)) {
                            return make_pair(
                                $kvs,
                                make_pair(
                                    SYMBOL_A,
                                    SYMBOL_NIL,
                                ),
                            );
                        }
                        $kvs = $bel->cdr($kvs);
                        return $loop->();
                    },
                );
            }

            return SYMBOL_NIL;
        };

        $loop->();
    }
    else {
        ELEM:
        while (!is_nil($kvs)) {
            my $kv = $bel->car($kvs);
            my @stack = [$bel->car($kv), $k];
            while (@stack) {
                my ($v0, $v1) = @{pop(@stack)};
                if (!is_pair($v0) || !is_pair($v1)) {
                    if (!atoms_are_identical($v0, $v1)) {
                        $kvs = $bel->cdr($kvs);
                        next ELEM;
                    }
                }
                else {
                    push @stack, [$bel->cdr($v0), $bel->cdr($v1)];
                    push @stack, [$bel->car($v0), $bel->car($v1)];
                }
            }
            return make_pair(
                $kvs,
                make_pair(
                    SYMBOL_A,
                    SYMBOL_NIL,
                ),
            );
        }

        return SYMBOL_NIL;
    }
}

sub fastfunc__put {
    my ($bel, $k, $v, $kvs, $f) = @_;

    my @values = make_pair($k, $v);
    if (defined($f)) {
        my $loop;
        my $after_loop;

        $loop = sub {
            while (!is_nil($kvs)) {
                my $kv = $bel->car($kvs);
                return make_async_call(
                    $f,
                    [$k, $bel->car($kv)],
                    sub {
                        my ($p) = @_;
                        if (is_nil($p)) {
                            push @values, $kv;
                        }
                        $kvs = $bel->cdr($kvs);
                        return $loop->();
                    },
                );
            }

            return $after_loop->();
        };

        $after_loop = sub {
            my $result = SYMBOL_NIL;
            for my $value (reverse(@values)) {
                $result = make_pair($value, $result);
            }
            return $result;
        };

        $loop->();
    }
    else {
        while (!is_nil($kvs)) {
            my $kv = $bel->car($kvs);
            my @stack = [$k, $bel->car($kv)];
            while (@stack) {
                my ($v0, $v1) = @{pop(@stack)};
                if (!is_pair($v0) || !is_pair($v1)) {
                    if (!atoms_are_identical($v0, $v1)) {
                        push @values, $kv;
                        last;
                    }
                }
                else {
                    push @stack, [$bel->cdr($v0), $bel->cdr($v1)];
                    push @stack, [$bel->car($v0), $bel->car($v1)];
                }
            }
            $kvs = $bel->cdr($kvs);
        }

        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    }
}

sub fastfunc__rev {
    my ($bel, $xs) = @_;

    my $result = SYMBOL_NIL;
    while (!is_nil($xs)) {
        $result = make_pair($bel->car($xs), $result);
        $xs = $bel->cdr($xs);
    }

    return $result;
}

sub fastfunc__snap {
    my ($bel, $xs, $ys, $acc) = @_;

    if (!defined($acc)) {
        $acc = SYMBOL_NIL;
    }

    my @values;
    while (!is_nil($acc)) {
        push @values, $bel->car($acc);
        $acc = $bel->cdr($acc);
    }

    while (!is_nil($xs)) {
        push @values, $bel->car($ys);
        $xs = $bel->cdr($xs);
        $ys = $bel->cdr($ys);
    }

    my $result = SYMBOL_NIL;
    for my $value (reverse(@values)) {
        $result = make_pair($value, $result);
    }

    return make_pair(
        $result,
        make_pair(
            $ys,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__udrop {
    my ($bel, $xs, $ys) = @_;

    while (!is_nil($xs)) {
        $xs = $bel->cdr($xs);
        $ys = $bel->cdr($ys);
    }

    return $ys;
}

sub fastfunc__idfn {
    my ($bel, $x) = @_;

    return $x;
}

sub fastfunc__where__idfn {
    my ($bel, $x) = @_;

    return make_pair(
        make_pair(
            make_symbol("x"),
            $x,
        ),
        make_pair(
            SYMBOL_D,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__literal {
    my ($bel, $e) = @_;

    return SYMBOL_T
        if is_symbol_of_name($e, "t")
        || is_nil($e)
        || is_symbol_of_name($e, "o")
        || is_symbol_of_name($e, "apply");

    return SYMBOL_T
        if is_char($e)
        || is_stream($e);

    return SYMBOL_T
        if is_pair($e)
        && is_symbol_of_name($bel->car($e), "lit");

    while (!is_nil($e)) {
        if (!is_pair($e)) {
            return SYMBOL_NIL;
        }
        if (!is_char($bel->car($e))) {
            return SYMBOL_NIL;
        }
        $e = $bel->cdr($e);
    }

    return SYMBOL_T;
}

sub fastfunc__variable {
    my ($bel, $e) = @_;

    if (is_pair($e)) {
        my $symbol_vmark = make_symbol("vmark");
        my $vmark = $bel->cdr($bel->lookup($symbol_vmark, SYMBOL_NIL));
        my $is_vmark = are_identical($bel->car($e), $vmark);
        return $is_vmark
            ? SYMBOL_T
            : SYMBOL_NIL;
    }
    else {
        return SYMBOL_NIL
            if is_symbol_of_name($e, "t")
            || is_nil($e)
            || is_symbol_of_name($e, "o")
            || is_symbol_of_name($e, "apply")
            || is_char($e)
            || is_stream($e);

        return SYMBOL_T;
    }
}

sub fastfunc__inwhere {
    my ($bel, $s) = @_;

    my $e = $bel->car($bel->car($s));

    return SYMBOL_NIL
        unless is_pair($e);

    my $symbol_smark = make_symbol("smark");
    my $smark = $bel->cdr($bel->lookup($symbol_smark, SYMBOL_NIL));
    return SYMBOL_NIL
        unless are_identical($bel->car($e), $smark);

    my $cdr = $bel->cdr($e);
    return SYMBOL_NIL
        unless is_symbol_of_name($bel->car($cdr), "loc");

    return $bel->cdr($cdr);
}

sub fastfunc__pairwise {
    my ($bel, $f, $xs) = @_;

    my $loop;
    $loop = sub {
        my $cdr_xs = $bel->cdr($xs);
        return SYMBOL_T
            if is_nil($cdr_xs);

        return make_async_call(
            $f,
            [$bel->car($xs), $bel->car($cdr_xs)],
            sub {
                my ($condition) = @_;

                return SYMBOL_NIL
                    if is_nil($condition);

                $xs = $cdr_xs;
                return $loop->();
            },
        );
    };

    return $loop->();
}

sub fastfunc__foldl {
    my ($bel, $f, $base, @args) = @_;

    return $base
        unless @args;

    my $loop;
    $loop = sub {
        my ($base, @args) = @_;

        return $base
            if grep { is_nil($_) } @args;

        my @car_args = map { $bel->car($_) } @args;
        return make_async_call(
            $f,
            [@car_args, $base],
            sub {
                my ($base) = @_;

                $loop->($base, map { $bel->cdr($_) } @args);
            },
        );
    };

    return $loop->($base, @args);
}

sub fastfunc__foldr {
    my ($bel, $f, $base, @args) = @_;

    return $base
        unless @args;

    my @cars;
    while (!grep { is_nil($_) } @args) {
        push @cars, [map { $bel->car($_) } @args];
        @args = map { $bel->cdr($_) } @args;
    }

    my @reverse_cars = reverse(@cars);

    my $loop;
    $loop = sub {
        my ($base, $i) = @_;

        return $base
            unless $i < @reverse_cars;

        return make_async_call(
            $f,
            [ @{ $reverse_cars[$i] }, $base ],
            sub {
                my ($base) = @_;

                $loop->($base, $i + 1);
            },
        );
    };

    return $loop->($base, 0);
}

sub fastfunc__fuse {
    my ($bel, $f, @args) = @_;

    my @sublists;
    my $min_length = -1;
    for my $list (@args) {
        my @sublist;
        while (!is_nil($list)) {
            push @sublist, $bel->car($list);
            $list = $bel->cdr($list);
        }
        push @sublists, \@sublist;
        my $length = scalar(@sublist);
        $min_length = $min_length == -1 || $length < $min_length
            ? $length
            : $min_length;
    }

    my $result_ref = [];
    my $loop;
    $loop = sub {
        my ($i) = @_;

        if ($i <= $min_length-1) {
            return make_async_call(
                $f,
                [ map { $sublists[$_]->[$i] } 0..$#sublists ],
                sub {
                    my ($r) = @_;
                    push @{ $result_ref }, $r;
                    $loop->($i + 1);
                },
            );
        }

        my $result = @{ $result_ref } ? pop(@{ $result_ref }) : SYMBOL_NIL;
        while (@{ $result_ref }) {
            my $list = pop(@{ $result_ref });
            my @values;
            while (!is_nil($list)) {
                push @values, $bel->car($list);
                $list = $bel->cdr($list);
            }
            while (@values) {
                my $value = pop(@values);
                $result = make_pair($value, $result);
            }
        }

        return $result;
    };

    return $loop->(0);
}

sub fastfunc__match {
    my ($bel, $x, $pat) = @_;

    my @stack = [$x, $pat];

    my $loop;
    $loop = sub {
        # no parameters

        while (@stack) {
            my ($v0, $v1) = @{pop(@stack)};
            if (is_symbol_of_name($v1, "t")) {
                # this subgoal succeeds
            }
            elsif (is_pair($v1)
                && is_symbol_of_name($bel->car($v1), "lit")
                && is_pair($bel->cdr($v1))
                && (is_symbol_of_name($bel->car($bel->cdr($v1)), "prim")
                    || is_symbol_of_name($bel->car($bel->cdr($v1)), "clo"))) {
                return make_async_call(
                    $v1,
                    [$v0],
                    sub {
                        my ($result) = @_;
                        if (is_nil($result)) {
                            return SYMBOL_NIL;
                        }
                        $loop->();
                    },
                );
            }
            elsif (!is_pair($v0) || !is_pair($v1)) {
                if (!atoms_are_identical($v0, $v1)) {
                    return SYMBOL_NIL;
                }
            }
            else {
                push @stack, [$bel->cdr($v0), $bel->cdr($v1)];
                push @stack, [$bel->car($v0), $bel->car($v1)];
            }
        }

        return SYMBOL_T;
    };

    return $loop->();
}

sub fastfunc__split {
    my ($bel, $f, $xs, $acc) = @_;

    if (!defined($acc)) {
        $acc = SYMBOL_NIL;
    }
    my @acc;
    my $loop;
    my $after_loop;

    $loop = sub {
        while (!is_nil($xs)) {
            return if !is_pair($xs);
            return make_async_call(
                $f,
                [$bel->car($xs)],
                sub {
                    my ($result) = @_;
                    return $after_loop->()
                        if !is_nil($result);
                    push(@acc, $bel->car($xs));
                    $xs = $bel->cdr($xs);
                    return $loop->();
                },
            );
        }

        $after_loop->();
    };

    $after_loop = sub {
        my @prefix;
        while (!is_nil($acc)) {
            push(@prefix, $bel->car($acc));
            $acc = $bel->cdr($acc);
        }
        my $first = SYMBOL_NIL;
        while (@acc) {
            $first = make_pair(pop(@acc), $first);
        }
        while (@prefix) {
            $first = make_pair(pop(@prefix), $first);
        }
        return make_pair(
            $first,
            make_pair(
                $xs,
                SYMBOL_NIL,
            ),
        );
    };

    return $loop->();
}

sub fastfunc__i_plus {
    my ($bel, @args) = @_;

    my $result = @args ? pop(@args) : SYMBOL_NIL;
    while (@args) {
        my $list = pop(@args);
        my @values;
        while (!is_nil($list)) {
            push @values, $bel->car($list);
            $list = $bel->cdr($list);
        }
        while (@values) {
            my $value = pop(@values);
            $result = make_pair($value, $result);
        }
    }

    return $result;
}

sub fastfunc__i_minus {
    my ($bel, $x, $y) = @_;

    while (!is_nil($x)) {
        if (is_nil($y)) {
            return make_pair(
                make_symbol("+"),
                make_pair(
                    $x,
                    SYMBOL_NIL,
                ),
            );
        }

        $x = $bel->cdr($x);
        $y = $bel->cdr($y);
    }

    return make_pair(
        make_symbol("-"),
        make_pair(
            $y,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__i_star {
    my ($bel, @args) = @_;

    my $product = 1;
    for my $arg (@args) {
        my $factor = 0;
        while (!is_nil($arg)) {
            $factor += 1;
            $arg = $bel->cdr($arg);
        }
        $product *= $factor;
    }

    my $result = SYMBOL_NIL;
    for (1..$product) {
        $result = make_pair(SYMBOL_T, $result);
    }
    return $result;
}

sub fastfunc__i_slash {
    my ($bel, $x, $y, $q) = @_;

    if (!defined($q)) {
        $q = SYMBOL_NIL;
    }

    my $xn = 0;
    while (!is_nil($x)) {
        $xn += 1;
        $x = $bel->cdr($x);
    }

    my $yn = 0;
    while (!is_nil($y)) {
        $yn += 1;
        $y = $bel->cdr($y);
    }

    my $n = int($xn / $yn);
    for (1..$n) {
        $q = make_pair(SYMBOL_T, $q);
    }

    my $m = $xn % $yn;
    my $remainder = SYMBOL_NIL;
    for (1..$m) {
        $remainder = make_pair(SYMBOL_T, $remainder);
    }

    return make_pair(
        $q,
        make_pair(
            $remainder,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__i_hat {
    my ($bel, $x, $y) = @_;

    my $xn = 0;
    while (!is_nil($x)) {
        $xn += 1;
        $x = $bel->cdr($x);
    }

    my $yn = 0;
    while (!is_nil($y)) {
        $yn += 1;
        $y = $bel->cdr($y);
    }

    my $n = $xn ** $yn;

    my $result = SYMBOL_NIL;
    for (1..$n) {
        $result = make_pair(SYMBOL_T, $result);
    }
    return $result;
}

sub fastfunc__r_plus {
    my ($bel, $x, $y) = @_;

    my $xn = $bel->car($x);
    my $xd = $bel->car($bel->cdr($x));

    my $yn = $bel->car($y);
    my $yd = $bel->car($bel->cdr($y));

    my $xn_n = 0;
    while (!is_nil($xn)) {
        ++$xn_n;
        $xn = $bel->cdr($xn);
    }

    my $xd_n = 0;
    while (!is_nil($xd)) {
        ++$xd_n;
        $xd = $bel->cdr($xd);
    }

    my $yn_n = 0;
    while (!is_nil($yn)) {
        ++$yn_n;
        $yn = $bel->cdr($yn);
    }

    my $yd_n = 0;
    while (!is_nil($yd)) {
        ++$yd_n;
        $yd = $bel->cdr($yd);
    }

    my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
    my $d_n = $xd_n * $yd_n;

    my $n = SYMBOL_NIL;
    for (1..$n_n) {
        $n = make_pair(
            SYMBOL_T,
            $n,
        );
    }

    my $d = SYMBOL_NIL;
    for (1..$d_n) {
        $d = make_pair(
            SYMBOL_T,
            $d,
        );
    }

    return make_pair(
        $n,
        make_pair(
            $d,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__r_minus {
    my ($bel, $x, $y) = @_;

    my $xn = $bel->car($x);
    my $xd = $bel->car($bel->cdr($x));

    my $yn = $bel->car($y);
    my $yd = $bel->car($bel->cdr($y));

    my $xn_n = 0;
    while (!is_nil($xn)) {
        ++$xn_n;
        $xn = $bel->cdr($xn);
    }

    my $xd_n = 0;
    while (!is_nil($xd)) {
        ++$xd_n;
        $xd = $bel->cdr($xd);
    }

    my $yn_n = 0;
    while (!is_nil($yn)) {
        ++$yn_n;
        $yn = $bel->cdr($yn);
    }

    my $yd_n = 0;
    while (!is_nil($yd)) {
        ++$yd_n;
        $yd = $bel->cdr($yd);
    }

    my $n_n = $xn_n * $yd_n - $yn_n * $xd_n;
    my $sign = $n_n < 1 ? "-" : "+";
    $n_n = abs($n_n);
    my $d_n = $xd_n * $yd_n;

    my $n = SYMBOL_NIL;
    for (1..$n_n) {
        $n = make_pair(
            SYMBOL_T,
            $n,
        );
    }

    my $d = SYMBOL_NIL;
    for (1..$d_n) {
        $d = make_pair(
            SYMBOL_T,
            $d,
        );
    }

    return make_pair(
        make_symbol($sign),
        make_pair(
            $n,
            make_pair(
                $d,
                SYMBOL_NIL,
            ),
        ),
    );
}

sub fastfunc__r_star {
    my ($bel, $x, $y) = @_;

    my $xn = $bel->car($x);
    my $xd = $bel->car($bel->cdr($x));

    my $yn = $bel->car($y);
    my $yd = $bel->car($bel->cdr($y));

    my $xn_n = 0;
    while (!is_nil($xn)) {
        ++$xn_n;
        $xn = $bel->cdr($xn);
    }

    my $xd_n = 0;
    while (!is_nil($xd)) {
        ++$xd_n;
        $xd = $bel->cdr($xd);
    }

    my $yn_n = 0;
    while (!is_nil($yn)) {
        ++$yn_n;
        $yn = $bel->cdr($yn);
    }

    my $yd_n = 0;
    while (!is_nil($yd)) {
        ++$yd_n;
        $yd = $bel->cdr($yd);
    }

    my $n_n = $xn_n * $yn_n;
    my $d_n = $xd_n * $yd_n;

    my $n = SYMBOL_NIL;
    for (1..$n_n) {
        $n = make_pair(
            SYMBOL_T,
            $n,
        );
    }

    my $d = SYMBOL_NIL;
    for (1..$d_n) {
        $d = make_pair(
            SYMBOL_T,
            $d,
        );
    }

    return make_pair(
        $n,
        make_pair(
            $d,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__r_slash {
    my ($bel, $x, $y) = @_;

    my $xn = $bel->car($x);
    my $xd = $bel->car($bel->cdr($x));

    my $yn = $bel->car($y);
    my $yd = $bel->car($bel->cdr($y));

    my $xn_n = 0;
    while (!is_nil($xn)) {
        ++$xn_n;
        $xn = $bel->cdr($xn);
    }

    my $xd_n = 0;
    while (!is_nil($xd)) {
        ++$xd_n;
        $xd = $bel->cdr($xd);
    }

    my $yn_n = 0;
    while (!is_nil($yn)) {
        ++$yn_n;
        $yn = $bel->cdr($yn);
    }

    my $yd_n = 0;
    while (!is_nil($yd)) {
        ++$yd_n;
        $yd = $bel->cdr($yd);
    }

    my $n_n = $xn_n * $yd_n;
    my $d_n = $xd_n * $yn_n;

    my $n = SYMBOL_NIL;
    for (1..$n_n) {
        $n = make_pair(
            SYMBOL_T,
            $n,
        );
    }

    my $d = SYMBOL_NIL;
    for (1..$d_n) {
        $d = make_pair(
            SYMBOL_T,
            $d,
        );
    }

    return make_pair(
        $n,
        make_pair(
            $d,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__sr_plus {
    my ($bel, $x, $y) = @_;

    my $xs = $bel->car($x);
    my $xn = $bel->car($bel->cdr($x));
    my $xd = $bel->car($bel->cdr($bel->cdr($x)));

    my $ys = $bel->car($y);
    my $yn = $bel->car($bel->cdr($y));
    my $yd = $bel->car($bel->cdr($bel->cdr($y)));

    my $symbol;
    if (is_symbol_of_name($xs, "-")) {
        if (is_symbol_of_name($ys, "-")) {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
            my $d_n = $xd_n * $yd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol("-"),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
        else {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $yn_n * $xd_n - $xn_n * $yd_n;
            my $sign = $n_n < 1 ? "-" : "+";
            $n_n = abs($n_n);
            my $d_n = $yd_n * $xd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol($sign),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
    }
    else {
        if (is_symbol_of_name($ys, "-")) {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $xn_n * $yd_n - $yn_n * $xd_n;
            my $sign = $n_n < 1 ? "-" : "+";
            $n_n = abs($n_n);
            my $d_n = $xd_n * $yd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol($sign),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
        else {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
            my $d_n = $xd_n * $yd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol("+"),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
    }
}

sub fastfunc__sr_minus {
    my ($bel, $x, $y) = @_;

    my $xs = $bel->car($x);
    my $xn = $bel->car($bel->cdr($x));
    my $xd = $bel->car($bel->cdr($bel->cdr($x)));

    my $ys = $bel->car($y);
    my $yn = $bel->car($bel->cdr($y));
    my $yd = $bel->car($bel->cdr($bel->cdr($y)));

    my $symbol;
    if (is_symbol_of_name($xs, "-")) {
        if (is_symbol_of_name($ys, "-")) {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $yn_n * $xd_n - $xn_n * $yd_n;
            my $sign = $n_n < 1 ? "-" : "+";
            $n_n = abs($n_n);
            my $d_n = $yd_n * $xd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol($sign),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
        else {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
            my $d_n = $xd_n * $yd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol("-"),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
    }
    else {
        if (is_symbol_of_name($ys, "-")) {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
            my $d_n = $xd_n * $yd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol("+"),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
        else {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $n_n = $xn_n * $yd_n - $yn_n * $xd_n;
            my $sign = $n_n < 1 && $yn_n > 0 ? "-" : "+";
            $n_n = abs($n_n);
            my $d_n = $xd_n * $yd_n;

            my $n = SYMBOL_NIL;
            for (1..$n_n) {
                $n = make_pair(
                    SYMBOL_T,
                    $n,
                );
            }

            my $d = SYMBOL_NIL;
            for (1..$d_n) {
                $d = make_pair(
                    SYMBOL_T,
                    $d,
                );
            }

            return make_pair(
                make_symbol($sign),
                make_pair(
                    $n,
                    make_pair(
                        $d,
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
    }
}

sub fastfunc__srinv {
    my ($bel, $sr) = @_;

    my $s = $bel->car($sr);
    my $n = $bel->car($bel->cdr($sr));
    my $d = $bel->car($bel->cdr($bel->cdr($sr)));

    my $sign = is_symbol_of_name($s, "+") && !is_nil($n)
        ? "-"
        : "+";

    return make_pair(
        make_symbol($sign),
        make_pair(
            $n,
            make_pair(
                $d,
                SYMBOL_NIL,
            ),
        ),
    );
}

sub fastfunc__sr_star {
    my ($bel, $x, $y) = @_;

    my $xs = $bel->car($x);
    my $xn = $bel->car($bel->cdr($x));
    my $xd = $bel->car($bel->cdr($bel->cdr($x)));

    my $ys = $bel->car($y);
    my $yn = $bel->car($bel->cdr($y));
    my $yd = $bel->car($bel->cdr($bel->cdr($y)));

    my $sign = is_symbol_of_name($xs, "-")
        ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
        : $ys;

    my $xn_n = 0;
    while (!is_nil($xn)) {
        ++$xn_n;
        $xn = $bel->cdr($xn);
    }

    my $xd_n = 0;
    while (!is_nil($xd)) {
        ++$xd_n;
        $xd = $bel->cdr($xd);
    }

    my $yn_n = 0;
    while (!is_nil($yn)) {
        ++$yn_n;
        $yn = $bel->cdr($yn);
    }

    my $yd_n = 0;
    while (!is_nil($yd)) {
        ++$yd_n;
        $yd = $bel->cdr($yd);
    }

    my $n_n = $xn_n * $yn_n;
    my $d_n = $xd_n * $yd_n;

    my $n = SYMBOL_NIL;
    for (1..$n_n) {
        $n = make_pair(
            SYMBOL_T,
            $n,
        );
    }

    my $d = SYMBOL_NIL;
    for (1..$d_n) {
        $d = make_pair(
            SYMBOL_T,
            $d,
        );
    }

    return make_pair(
        $sign,
        make_pair(
            $n,
            make_pair(
                $d,
                SYMBOL_NIL,
            ),
        ),
    );
}

sub fastfunc__sr_slash {
    my ($bel, $x, $y) = @_;

    my $xs = $bel->car($x);
    my $xn = $bel->car($bel->cdr($x));
    my $xd = $bel->car($bel->cdr($bel->cdr($x)));

    my $ys = $bel->car($y);
    my $yn = $bel->car($bel->cdr($y));
    my $yd = $bel->car($bel->cdr($bel->cdr($y)));

    die "mistype\n"
        if is_nil($yn);

    my $sign = is_symbol_of_name($xs, "-")
        ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
        : $ys;

    my $xn_n = 0;
    while (!is_nil($xn)) {
        ++$xn_n;
        $xn = $bel->cdr($xn);
    }

    my $xd_n = 0;
    while (!is_nil($xd)) {
        ++$xd_n;
        $xd = $bel->cdr($xd);
    }

    my $yn_n = 0;
    while (!is_nil($yn)) {
        ++$yn_n;
        $yn = $bel->cdr($yn);
    }

    my $yd_n = 0;
    while (!is_nil($yd)) {
        ++$yd_n;
        $yd = $bel->cdr($yd);
    }

    my $n_n = $xn_n * $yd_n;
    my $d_n = $xd_n * $yn_n;

    my $n = SYMBOL_NIL;
    for (1..$n_n) {
        $n = make_pair(
            SYMBOL_T,
            $n,
        );
    }

    my $d = SYMBOL_NIL;
    for (1..$d_n) {
        $d = make_pair(
            SYMBOL_T,
            $d,
        );
    }

    return make_pair(
        $sign,
        make_pair(
            $n,
            make_pair(
                $d,
                SYMBOL_NIL,
            ),
        ),
    );
}

sub fastfunc__srrecip {
    my ($bel, $sr) = @_;

    my $s = $bel->car($sr);
    my $n = $bel->car($bel->cdr($sr));
    die "mistype\n"
        if is_nil($n);
    my $d = $bel->car($bel->cdr($bel->cdr($sr)));

    return make_pair(
        $s,
        make_pair(
            $d,
            make_pair(
                $n,
                SYMBOL_NIL,
            ),
        ),
    );
}

sub fastfunc__sr_lt {
    my ($bel, $x, $y) = @_;

    my $xs = $bel->car($x);
    my $xn = $bel->car($bel->cdr($x));
    my $xd = $bel->car($bel->cdr($bel->cdr($x)));

    my $ys = $bel->car($y);
    my $yn = $bel->car($bel->cdr($y));
    my $yd = $bel->car($bel->cdr($bel->cdr($y)));

    if (is_symbol_of_name($xs, "+")) {
        if (is_symbol_of_name($ys, "+")) {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $p1_n = $xn_n * $yd_n;
            my $p2_n = $yn_n * $xd_n;

            my $n = $p2_n - $p1_n;
            my $result = SYMBOL_NIL;
            for (1..$n) {
                $result = make_pair(SYMBOL_T, $result);
            }
            return $result;
        }
        else {
            return SYMBOL_NIL;
        }
    }
    else {
        if (is_symbol_of_name($ys, "+")) {
            return !is_nil($xn) || !is_nil($yn)
                ? SYMBOL_T
                : SYMBOL_NIL;
        }
        else {
            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            my $p1_n = $yn_n * $xd_n;
            my $p2_n = $xn_n * $yd_n;

            my $n = $p2_n - $p1_n;
            my $result = SYMBOL_NIL;
            for (1..$n) {
                $result = make_pair(SYMBOL_T, $result);
            }
            return $result;
        }
    }
}

sub fastfunc__c_plus {
    my ($bel, $x, $y) = @_;

    my $xr = $bel->car($x);
    my $xi = $bel->car($bel->cdr($x));

    my $yr = $bel->car($y);
    my $yi = $bel->car($bel->cdr($y));

    my $real_part;
    {
        my $xs = $bel->car($xr);
        my $xn = $bel->car($bel->cdr($xr));
        my $xd = $bel->car($bel->cdr($bel->cdr($xr)));

        my $ys = $bel->car($yr);
        my $yn = $bel->car($bel->cdr($yr));
        my $yd = $bel->car($bel->cdr($bel->cdr($yr)));

        my $symbol;
        if (is_symbol_of_name($xs, "-")) {
            if (is_symbol_of_name($ys, "-")) {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
                my $d_n = $xd_n * $yd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol("-"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $yn_n * $xd_n - $xn_n * $yd_n;
                my $sign = $n_n < 1 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $yd_n * $xd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
        else {
            if (is_symbol_of_name($ys, "-")) {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $xn_n * $yd_n - $yn_n * $xd_n;
                my $sign = $n_n < 1 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $xd_n * $yd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
                my $d_n = $xd_n * $yd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol("+"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
    }

    my $imaginary_part;
    {
        my $xs = $bel->car($xi);
        my $xn = $bel->car($bel->cdr($xi));
        my $xd = $bel->car($bel->cdr($bel->cdr($xi)));

        my $ys = $bel->car($yi);
        my $yn = $bel->car($bel->cdr($yi));
        my $yd = $bel->car($bel->cdr($bel->cdr($yi)));

        my $symbol;
        if (is_symbol_of_name($xs, "-")) {
            if (is_symbol_of_name($ys, "-")) {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
                my $d_n = $xd_n * $yd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol("-"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $yn_n * $xd_n - $xn_n * $yd_n;
                my $sign = $n_n < 1 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $yd_n * $xd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
        else {
            if (is_symbol_of_name($ys, "-")) {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $xn_n * $yd_n - $yn_n * $xd_n;
                my $sign = $n_n < 1 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $xd_n * $yd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = $bel->cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = $bel->cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = $bel->cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = $bel->cdr($yd);
                }

                my $n_n = $xn_n * $yd_n + $yn_n * $xd_n;
                my $d_n = $xd_n * $yd_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol("+"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
    }

    return make_pair(
        $real_part,
        make_pair(
            $imaginary_part,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__c_star {
    my ($bel, $x, $y) = @_;

    my $xr = $bel->car($x);
    my $xi = $bel->car($bel->cdr($x));

    my $yr = $bel->car($y);
    my $yi = $bel->car($bel->cdr($y));

    my $real_part;
    {
        my $term1s;
        my $term1n_n;
        my $term1d_n;

        {
            my $xs = $bel->car($xr);
            my $xn = $bel->car($bel->cdr($xr));
            my $xd = $bel->car($bel->cdr($bel->cdr($xr)));

            my $ys = $bel->car($yr);
            my $yn = $bel->car($bel->cdr($yr));
            my $yd = $bel->car($bel->cdr($bel->cdr($yr)));

            $term1s = is_symbol_of_name($xs, "-")
                ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                : $ys;

            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            $term1n_n = $xn_n * $yn_n;
            $term1d_n = $xd_n * $yd_n;
        }

        my $term2s;
        my $term2n_n;
        my $term2d_n;

        {
            my $xs = $bel->car($xi);
            my $xn = $bel->car($bel->cdr($xi));
            my $xd = $bel->car($bel->cdr($bel->cdr($xi)));

            my $ys = $bel->car($yi);
            my $yn = $bel->car($bel->cdr($yi));
            my $yd = $bel->car($bel->cdr($bel->cdr($yi)));

            $term2s = is_symbol_of_name($xs, "-")
                ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                : $ys;

            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            $term2n_n = $xn_n * $yn_n;
            $term2d_n = $xd_n * $yd_n;
        }

        if (is_symbol_of_name($term1s, "-")) {
            if (is_symbol_of_name($term2s, "-")) {
                my $n_n = $term2n_n * $term1d_n - $term1n_n * $term2d_n;
                my $sign = $n_n < 1 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $term2d_n * $term1d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $n_n = $term1n_n * $term2d_n + $term2n_n * $term1d_n;
                my $d_n = $term1d_n * $term2d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol("-"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
        else {
            if (is_symbol_of_name($term2s, "-")) {
                my $n_n = $term1n_n * $term2d_n + $term2n_n * $term1d_n;
                my $d_n = $term1d_n * $term2d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol("+"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $n_n = $term1n_n * $term2d_n - $term2n_n * $term1d_n;
                my $sign = $n_n < 1 && $term2n_n > 0 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $term1d_n * $term2d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $real_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
    }

    my $imaginary_part;
    {
        my $term1s;
        my $term1n_n;
        my $term1d_n;

        {
            my $xs = $bel->car($xi);
            my $xn = $bel->car($bel->cdr($xi));
            my $xd = $bel->car($bel->cdr($bel->cdr($xi)));

            my $ys = $bel->car($yr);
            my $yn = $bel->car($bel->cdr($yr));
            my $yd = $bel->car($bel->cdr($bel->cdr($yr)));

            $term1s = is_symbol_of_name($xs, "-")
                ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                : $ys;

            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            $term1n_n = $xn_n * $yn_n;
            $term1d_n = $xd_n * $yd_n;
        }

        my $term2s;
        my $term2n_n;
        my $term2d_n;

        {
            my $xs = $bel->car($xr);
            my $xn = $bel->car($bel->cdr($xr));
            my $xd = $bel->car($bel->cdr($bel->cdr($xr)));

            my $ys = $bel->car($yi);
            my $yn = $bel->car($bel->cdr($yi));
            my $yd = $bel->car($bel->cdr($bel->cdr($yi)));

            $term2s = is_symbol_of_name($xs, "-")
                ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                : $ys;

            my $xn_n = 0;
            while (!is_nil($xn)) {
                ++$xn_n;
                $xn = $bel->cdr($xn);
            }

            my $xd_n = 0;
            while (!is_nil($xd)) {
                ++$xd_n;
                $xd = $bel->cdr($xd);
            }

            my $yn_n = 0;
            while (!is_nil($yn)) {
                ++$yn_n;
                $yn = $bel->cdr($yn);
            }

            my $yd_n = 0;
            while (!is_nil($yd)) {
                ++$yd_n;
                $yd = $bel->cdr($yd);
            }

            $term2n_n = $xn_n * $yn_n;
            $term2d_n = $xd_n * $yd_n;
        }

        if (is_symbol_of_name($term1s, "-")) {
            if (is_symbol_of_name($term2s, "-")) {
                my $n_n = $term1n_n * $term2d_n + $term2n_n * $term1d_n;
                my $d_n = $term1d_n * $term2d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol("-"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $n_n = $term2n_n * $term1d_n - $term1n_n * $term2d_n;
                my $sign = $n_n < 1 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $term2d_n * $term1d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
        else {
            if (is_symbol_of_name($term2s, "-")) {
                my $n_n = $term1n_n * $term2d_n - $term2n_n * $term1d_n;
                my $sign = $n_n < 1 ? "-" : "+";
                $n_n = abs($n_n);
                my $d_n = $term1d_n * $term2d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol($sign),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            else {
                my $n_n = $term1n_n * $term2d_n + $term2n_n * $term1d_n;
                my $d_n = $term1d_n * $term2d_n;

                my $n = SYMBOL_NIL;
                for (1..$n_n) {
                    $n = make_pair(
                        SYMBOL_T,
                        $n,
                    );
                }

                my $d = SYMBOL_NIL;
                for (1..$d_n) {
                    $d = make_pair(
                        SYMBOL_T,
                        $d,
                    );
                }

                $imaginary_part = make_pair(
                    make_symbol("+"),
                    make_pair(
                        $n,
                        make_pair(
                            $d,
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
        }
    }

    return make_pair(
        $real_part,
        make_pair(
            $imaginary_part,
            SYMBOL_NIL,
        ),
    );
}

sub fastfunc__litnum {
    my ($bel, $r, $i) = @_;

    if (!defined($i)) {
        $i = make_pair(
            make_symbol("+"),
            make_pair(
                SYMBOL_NIL,
                make_pair(
                    make_pair(
                        SYMBOL_T,
                        SYMBOL_NIL,
                    ),
                    SYMBOL_NIL,
                ),
            ),
        );
    }

    return make_pair(
        make_symbol("lit"),
        make_pair(
            make_symbol("num"),
            make_pair(
                $r,
                make_pair(
                    $i,
                    SYMBOL_NIL,
                ),
            ),
        ),
    );
}

sub fastfunc__number {
    my ($bel, $x) = @_;

    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "lit")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "num")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!(is_symbol_of_name($sign, "+") || is_symbol_of_name($sign, "-"))) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
            }
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
            }
        }
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!(is_symbol_of_name($sign, "+") || is_symbol_of_name($sign, "-"))) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
            }
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
            }
        }
    }

    return SYMBOL_T;
}

sub fastfunc__numr {
    my ($bel, $x) = @_;

    return $bel->car($bel->cdr($bel->cdr($x)));
}

sub fastfunc__numi {
    my ($bel, $x) = @_;

    return $bel->car($bel->cdr($bel->cdr($bel->cdr($x))));
}

sub fastfunc__rpart {
    my ($bel, $n) = @_;

    my $numr = $bel->car($bel->cdr($bel->cdr($n)));

    my $i = make_pair(
        make_symbol("+"),
        make_pair(
            SYMBOL_NIL,
            make_pair(
                make_pair(
                    SYMBOL_T,
                    SYMBOL_NIL,
                ),
                SYMBOL_NIL,
            ),
        ),
    );

    return make_pair(
        make_symbol("lit"),
        make_pair(
            make_symbol("num"),
            make_pair(
                $numr,
                make_pair(
                    $i,
                    SYMBOL_NIL,
                ),
            ),
        ),
    );
}

sub fastfunc__ipart {
    my ($bel, $n) = @_;

    my $numi = $bel->car($bel->cdr($bel->cdr($bel->cdr($n))));

    my $i = make_pair(
        make_symbol("+"),
        make_pair(
            SYMBOL_NIL,
            make_pair(
                make_pair(
                    SYMBOL_T,
                    SYMBOL_NIL,
                ),
                SYMBOL_NIL,
            ),
        ),
    );

    return make_pair(
        make_symbol("lit"),
        make_pair(
            make_symbol("num"),
            make_pair(
                $numi,
                make_pair(
                    $i,
                    SYMBOL_NIL,
                ),
            ),
        ),
    );
}

sub fastfunc__real {
    my ($bel, $x) = @_;

    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "lit")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "num")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!(is_symbol_of_name($sign, "+") || is_symbol_of_name($sign, "-"))) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
            }
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
            }
        }
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!is_symbol_of_name($sign, "+")) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        if (!is_nil($bel->car($y))) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            my $t = 0;
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
                $t++;
            }

            if ($t != 1) {
                return SYMBOL_NIL;
            }
        }
    }

    return SYMBOL_T;
}

sub fastfunc__int {
    my ($bel, $x) = @_;

    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "lit")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "num")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!(is_symbol_of_name($sign, "+") || is_symbol_of_name($sign, "-"))) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
            }
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        my $denominator = 0;
        {
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
                $denominator++;
            }
        }

        if ($denominator != 1) {
            return SYMBOL_NIL;
        }
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!is_symbol_of_name($sign, "+")) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        if (!is_nil($bel->car($y))) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            my $t = 0;
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
                $t++;
            }

            if ($t != 1) {
                return SYMBOL_NIL;
            }
        }
    }

    return SYMBOL_T;
}

sub fastfunc__pint {
    my ($bel, $x) = @_;

    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "lit")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    if (!is_symbol_of_name($bel->car($x), "num")) {
        return SYMBOL_NIL;
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!is_symbol_of_name($sign, "+")) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $numerator = 0;
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
                $numerator++;
            }
            if ($numerator == 0) {
                return SYMBOL_NIL;
            }
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $denominator = 0;
            my $z = $bel->car($y);
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
                $denominator++;
            }

            if ($denominator != 1) {
                return SYMBOL_NIL;
            }
        }
    }

    $x = $bel->cdr($x);
    if (!is_pair($x)) {
        return SYMBOL_NIL;
    }

    {
        my $y = $bel->car($x);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }


        my $sign = $bel->car($y);
        if (!is_symbol_of_name($sign, "+")) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        if (!is_nil($bel->car($y))) {
            return SYMBOL_NIL;
        }

        $y = $bel->cdr($y);
        if (!is_pair($y)) {
            return SYMBOL_NIL;
        }

        {
            my $z = $bel->car($y);
            my $t = 0;
            while (!is_nil($z)) {
                if (!is_pair($z)) {
                    return SYMBOL_NIL;
                }
                $z = $bel->cdr($z);
                $t++;
            }

            if ($t != 1) {
                return SYMBOL_NIL;
            }
        }
    }

    return SYMBOL_T;
}

sub fastfunc__charn {
    my ($bel, $c) = @_;

    if (!is_char($c)) {
        die "not-a-char\n";
    }

    my $n = char_codepoint($c);
    return make_num(
        make_signed_rat("+", $n, 1),
        make_signed_rat("+", 0, 1),
    );
}

sub fastfunc__deq {
    my ($bel, $q) = @_;

    my $do1 = $bel->car($bel->car($q));
    $bel->xar($q, $bel->cdr($bel->car($q)));
    return $do1;
}

sub fastfunc__prn {
    my ($bel, @args) = @_;

    my $last = SYMBOL_NIL;
    for (@args) {
        $bel->output(Language::Bel::Printer::_print($_));
        $bel->output(" ");
        $last = $_;
    }
    $bel->output("\n");
    return $last;
}

sub fastfunc__pr {
    my ($bel, @args) = @_;

    $bel->output($_) for
        map { Language::Bel::Printer::prnice($_) }
        @args;

    my $result = SYMBOL_NIL;
    while (@args) {
        $result = make_pair(pop(@args), $result);
    }
    return $result;
}

sub fastfunc__prs {
    my ($bel, @args) = @_;

    my @strings;
    for (@args) {
        push(@strings, Language::Bel::Printer::prnice($_));
    }

    return make_str(join("", @strings));
}

sub fastfunc__len {
    my ($bel, $xs) = @_;

    my $length;
    if (is_str($xs)) {
        $length = length($xs->string());
    }
    else {
        $length = 0;
        while (!is_nil($xs)) {
            $xs = $bel->cdr($xs);
            ++$length;
        }
    }

    my $srzero = make_signed_rat("+", 0, 1);

    return make_num(
        make_signed_rat("+", $length, 1),
        $srzero,
    );
}

sub fastfunc__nchar {
    my ($bel, $n) = @_;

    my $nn = maybe_get_int($bel, $n);
    die "mistype\n"
        unless defined($nn);
    die "mistype\n"
        unless $nn >= 0;

    return make_char($nn);
}

sub fastfunc__dedup  {
    my ($bel, $xs, $f) = @_;

    my @result;

    if (defined($f)) {
        my $loop1;
        $loop1 = sub {
            while (!is_nil($xs)) {
                my $candidate = $bel->car($xs);
                my $candidate_is_duplicate = 0;   # until we find an identical
                                                  # element in @result

                my $loop2;
                my $after_loop2;

                $loop2 = sub {
                    my ($i) = @_;

                    if ($i < scalar(@result)) {
                        my $element = $result[$i];
                        return make_async_call(
                            $f,
                            [$element, $candidate],
                            sub {
                                my ($r) = @_;
                                if (!is_nil($r)) {
                                    $candidate_is_duplicate = 1;
                                    return $after_loop2->();
                                }
                                return $loop2->($i + 1);
                            },
                        );
                    }
                    else {
                        return $after_loop2->();
                    }
                };

                $after_loop2 = sub {
                    if (!$candidate_is_duplicate) {
                        push @result, $candidate;
                    }
                    $xs = $bel->cdr($xs);
                    return $loop1->();
                };

                return $loop2->(0);
            }

            my $result = SYMBOL_NIL;
            my $result_tail;
            for my $e (@result) {
                my $new_pair = make_pair($e, SYMBOL_NIL);
                if (is_nil($result)) {
                    $result = $new_pair;
                }
                else {
                    $bel->xdr($result_tail, $new_pair);
                }
                $result_tail = $new_pair;
            }

            return $result;
        };

        return $loop1->();
    }
    else {
        while (!is_nil($xs)) {
            my $candidate = $bel->car($xs);
            my $candidate_is_duplicate = 0;   # until we find an identical
                                              # element in @results

            ELEMENT:
            for my $element (@result) {
                my @stack = [$candidate, $element];

                my $candidate_and_element_identical = 1;    # until proven
                                                            # different
                IDENTITY_CHECK:
                while (@stack) {
                    my @values = @{pop(@stack)};
                    next unless @values;
                    my $some_atom = "";
                    for my $value (@values) {
                        if (!is_pair($value)) {
                            $some_atom = 1;
                            last;
                        }
                    }
                    if ($some_atom) {
                        my $car_values = $values[0];
                        for my $value (@values) {
                            if (!atoms_are_identical($value, $car_values)) {
                                $candidate_and_element_identical = 0;
                                last IDENTITY_CHECK;
                            }
                        }
                    }
                    else {
                        push @stack, [map { $bel->cdr($_) } @values];
                        push @stack, [map { $bel->car($_) } @values];
                    }
                }
                if ($candidate_and_element_identical) {
                    $candidate_is_duplicate = 1;
                    last ELEMENT;
                }
            }

            if (!$candidate_is_duplicate) {
                push @result, $candidate;
            }
            $xs = $bel->cdr($xs);
        }

        my $result = SYMBOL_NIL;
        my $result_tail;
        for my $e (@result) {
            my $new_pair = make_pair($e, SYMBOL_NIL);
            if (is_nil($result)) {
                $result = $new_pair;
            }
            else {
                $bel->xdr($result_tail, $new_pair);
            }
            $result_tail = $new_pair;
        }

        return $result;
    }
}

sub fastfunc__randlen {
    my ($bel, $n) = @_;

    my $nn = maybe_get_int($bel, $n);
    if (!defined($nn)) {
        die "incomparable\n";
    }

    if ($nn == 0) {
        return SYMBOL_NIL;
    }

    my $result = 0;
    for (my $i = 0; $i < $nn; $i++) {
        $result *= 2;
        $result += rand() < 0.5 ? 1 : 0;
    }

    my $srzero = make_signed_rat("+", 0, 1);

    return make_num(
        make_signed_rat("+", $result, 1),
        $srzero,
    );
}

sub fastfunc__rand {
    my ($bel, $n) = @_;

    my $nn = maybe_get_int($bel, $n);
    if (!defined($nn) || $nn < 1) {
        die "mistype\n";
    }

    my $rand = int(rand() * $nn);
    my $srzero = make_signed_rat("+", 0, 1);

    return make_num(
        make_signed_rat("+", $rand, 1),
        $srzero,
    );
}

sub fastfunc__array {
    my ($bel, $dims, $default) = @_;

    if (!defined($default)) {
        $default = SYMBOL_NIL;
    }

    if (is_nil($dims)) {
        return $default;
    }

    my $car_dims = $bel->car($dims);
    my $n = maybe_get_int($bel, $car_dims);
    die "mistype\n"
        unless defined($n);
    my $result = SYMBOL_NIL;
    for (1 .. $n) {
        $result = make_pair(
            fastfunc__array($bel, $bel->cdr($dims), $default),
            $result,
        );
    }
    $result = make_pair(
        make_symbol("lit"),
        make_pair(
            make_symbol("arr"),
            $result,
        ),
    );

    return $result;
}

sub fastfunc__err {
    my ($bel, $msg) = @_;

    die _print($msg), "\n";
}

our @EXPORT_OK = qw(
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
    fastfunc__stream
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
    fastfunc__literal
    fastfunc__variable
    fastfunc__inwhere
    fastfunc__pairwise
    fastfunc__foldl
    fastfunc__foldr
    fastfunc__fuse
    fastfunc__match
    fastfunc__split
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
    fastfunc__c_plus
    fastfunc__c_star
    fastfunc__litnum
    fastfunc__number
    fastfunc__numr
    fastfunc__numi
    fastfunc__rpart
    fastfunc__ipart
    fastfunc__real
    fastfunc__int
    fastfunc__pint
    fastfunc__charn
    fastfunc__deq
    fastfunc__prn
    fastfunc__pr
    fastfunc__prs
    fastfunc__len
    fastfunc__nchar
    fastfunc__dedup
    fastfunc__randlen
    fastfunc__rand
    fastfunc__array
    fastfunc__err
);

1;
