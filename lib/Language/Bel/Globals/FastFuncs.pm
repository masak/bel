package Language::Bel::Globals::FastFuncs;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_char
    is_nil
    is_pair
    is_symbol
    is_symbol_of_name
    make_char
    make_pair
    make_symbol
);
use Language::Bel::Primitives qw(
    _id
    prim_car
    prim_cdr
    prim_id
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_A
    SYMBOL_D
    SYMBOL_NIL
    SYMBOL_T
);
use Language::Bel::Printer;

use Exporter 'import';

my %FASTFUNCS = (
    "no" => sub {
        my ($call, $x) = @_;

        return is_nil($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "atom" => sub {
        my ($call, $x) = @_;

        return is_pair($x) ? SYMBOL_NIL : SYMBOL_T;
    },

    "all" => sub {
        my ($call, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $p = $call->($f, prim_car($xs));
            if (is_nil($p)) {
                return SYMBOL_NIL;
            }
            $xs = prim_cdr($xs);
        }

        return SYMBOL_T;
    },

    "some" => sub {
        my ($call, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $p = $call->($f, prim_car($xs));
            if (!is_nil($p)) {
                return $xs;
            }
            $xs = prim_cdr($xs);
        }

        return SYMBOL_NIL;
    },

    "where__some" => sub {
        my ($call, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $p = $call->($f, prim_car($xs));
            if (!is_nil($p)) {
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
            $xs = prim_cdr($xs);
        }

        return SYMBOL_NIL;
    },

    "reduce" => sub {
        my ($call, $f, $xs) = @_;

        my @values;
        while (!is_nil($xs)) {
            push @values, prim_car($xs);
            $xs = prim_cdr($xs);
        }

        my $result = @values ? pop(@values) : SYMBOL_NIL;
        while (@values) {
            my $value = pop(@values);
            $result = $call->($f, $value, $result);
        }

        return $result;
    },

    "cons" => sub {
        my ($call, @args) = @_;

        my $result = @args ? pop(@args) : SYMBOL_NIL;
        while (@args) {
            my $value = pop(@args);
            $result = make_pair($value, $result);
        }

        return $result;
    },

    "append" => sub {
        my ($call, @args) = @_;

        my $result = @args ? pop(@args) : SYMBOL_NIL;
        while (@args) {
            my $list = pop(@args);
            my @values;
            while (!is_nil($list)) {
                push @values, prim_car($list);
                $list = prim_cdr($list);
            }
            while (@values) {
                my $value = pop(@values);
                $result = make_pair($value, $result);
            }
        }

        return $result;
    },

    "snoc" => sub {
        my ($call, @args) = @_;

        my $result = SYMBOL_NIL;
        while (scalar(@args) > 1) {
            my $value = pop(@args);
            $result = make_pair($value, $result);
        }
        if (@args) {
            my $list = pop(@args);
            my @values;
            while (!is_nil($list)) {
                push @values, prim_car($list);
                $list = prim_cdr($list);
            }
            while (@values) {
                my $value = pop(@values);
                $result = make_pair($value, $result);
            }
        }

        return $result;
    },

    "list" => sub {
        my ($call, @args) = @_;

        my $result = SYMBOL_NIL;
        while (@args) {
            my $value = pop(@args);
            $result = make_pair($value, $result);
        }

        return $result;
    },

    "map" => sub {
        my ($call, $f, @ls) = @_;

        return SYMBOL_NIL
            unless @ls;
        my @sublists;
        my $min_length = -1;
        for my $list (@ls) {
            my @sublist;
            while (!is_nil($list)) {
                push @sublist, prim_car($list);
                $list = prim_cdr($list);
            }
            push @sublists, \@sublist;
            my $length = scalar(@sublist);
            $min_length = $min_length == -1 || $length < $min_length
                ? $length
                : $min_length;
        }
        my @result;
        for my $i (0..$min_length-1) {
            push @result, $call->(
                $f,
                map { $sublists[$_]->[$i] } 0..$#sublists
            );
        }
        my $result = SYMBOL_NIL;
        for my $v (reverse(@result)) {
            $result = make_pair($v, $result);
        }

        return $result;
    },

    "=" => sub {
        my ($call, @args) = @_;

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
                    if (!_id($value, $car_values)) {
                        return SYMBOL_NIL;
                    }
                }
            }
            else {
                push @stack, [map { prim_cdr($_) } @values];
                push @stack, [map { prim_car($_) } @values];
            }
        }

        return SYMBOL_T;
    },

    "symbol" => sub {
        my ($call, $x) = @_;

        return is_symbol($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "pair" => sub {
        my ($call, $x) = @_;

        return is_pair($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "char" => sub {
        my ($call, $x) = @_;

        return is_char($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "proper" => sub {
        my ($call, $x) = @_;

        while (!is_nil($x)) {
            if (!is_pair($x)) {
                return SYMBOL_NIL;
            }
            $x = prim_cdr($x);
        }

        return SYMBOL_T;
    },

    "string" => sub {
        my ($call, $x) = @_;

        while (!is_nil($x)) {
            if (!is_pair($x)) {
                return SYMBOL_NIL;
            }
            if (!is_char(prim_car($x))) {
                return SYMBOL_NIL;
            }
            $x = prim_cdr($x);
        }

        return SYMBOL_T;
    },

    "mem" => sub {
        my ($call, $x, $ys, $f) = @_;

        if (defined($f)) {
            while (!is_nil($ys)) {
                my $p = $call->($f, prim_car($ys), $x);
                if (!is_nil($p)) {
                    return $ys;
                }
                $ys = prim_cdr($ys);
            }
        }
        else {
            ELEMENT:
            while (!is_nil($ys)) {
                my @stack = [prim_car($ys), $x];
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
                            if (!_id($value, $car_values)) {
                                $ys = prim_cdr($ys);
                                next ELEMENT;
                            }
                        }
                    }
                    else {
                        push @stack, [map { prim_cdr($_) } @values];
                        push @stack, [map { prim_car($_) } @values];
                    }
                }

                return $ys;
            }
        }

        return SYMBOL_NIL;
    },

    "where__mem" => sub {
        my ($call, $x, $ys, $f) = @_;

        if (defined($f)) {
            while (!is_nil($ys)) {
                my $p = $call->($f, prim_car($ys), $x);
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
                $ys = prim_cdr($ys);
            }
        }
        else {
            ELEMENT:
            while (!is_nil($ys)) {
                my @stack = [prim_car($ys), $x];
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
                            if (!_id($value, $car_values)) {
                                $ys = prim_cdr($ys);
                                next ELEMENT;
                            }
                        }
                    }
                    else {
                        push @stack, [map { prim_cdr($_) } @values];
                        push @stack, [map { prim_car($_) } @values];
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
        }

        return SYMBOL_NIL;
    },

    "in" => sub {
        my ($call, @args) = @_;

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
                        if (!_id($value, $car_values)) {
                            shift(@args);
                            next ARG;
                        }
                    }
                }
                else {
                    push @stack, [map { prim_cdr($_) } @values];
                    push @stack, [map { prim_car($_) } @values];
                }
            }
            last ARG;
        }

        my $ys = SYMBOL_NIL;
        while (@args) {
            $ys = make_pair(pop(@args), $ys);
        }
        return $ys;
    },

    "where__in" => sub {
        my ($call, @args) = @_;

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
                        if (!_id($value, $car_values)) {
                            shift(@args);
                            next ARG;
                        }
                    }
                }
                else {
                    push @stack, [map { prim_cdr($_) } @values];
                    push @stack, [map { prim_car($_) } @values];
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
    },

    "cadr" => sub {
        my ($call, $x) = @_;

        return prim_car(prim_cdr($x));
    },

    "where__cadr" => sub {
        my ($call, $x) = @_;

        return make_pair(
            prim_cdr($x),
            make_pair(
                SYMBOL_A,
                SYMBOL_NIL,
            ),
        );
    },

    "cddr" => sub {
        my ($call, $x) = @_;

        return prim_cdr(prim_cdr($x));
    },

    "where__cddr" => sub {
        my ($call, $x) = @_;

        return make_pair(
            prim_cdr($x),
            make_pair(
                SYMBOL_D,
                SYMBOL_NIL,
            ),
        );
    },

    "caddr" => sub {
        my ($call, $x) = @_;

        return prim_car(prim_cdr(prim_cdr($x)));
    },

    "where__caddr" => sub {
        my ($call, $x) = @_;

        return make_pair(
            prim_cdr(prim_cdr($x)),
            make_pair(
                SYMBOL_A,
                SYMBOL_NIL,
            ),
        );
    },

    "find" => sub {
        my ($call, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $value = prim_car($xs);
            if (!is_nil($call->($f, $value))) {
                return $value;
            }
            $xs = prim_cdr($xs);
        }
        return SYMBOL_NIL;
    },

    "where__find" => sub {
        my ($call, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $value = prim_car($xs);
            if (!is_nil($call->($f, $value))) {
                return make_pair(
                    $xs,
                    make_pair(
                        SYMBOL_A,
                        SYMBOL_NIL,
                    ),
                );
            }
            $xs = prim_cdr($xs);
        }
        return SYMBOL_NIL;
    },

    "begins" => sub {
        my ($call, $xs, $pat, $f) = @_;

        if (defined($f)) {
            while (!is_nil($pat)) {
                if (!is_pair($xs)) {
                    return SYMBOL_NIL;
                }
                else {
                    my $p = $call->($f, prim_car($xs), prim_car($pat));
                    if (is_nil($p)) {
                        return SYMBOL_NIL;
                    }
                }
                $xs = prim_cdr($xs);
                $pat = prim_cdr($pat);
            }
        }
        else {
            while (!is_nil($pat)) {
                if (!is_pair($xs)) {
                    return SYMBOL_NIL;
                }

                my @stack = [prim_car($xs), prim_car($pat)];
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
                            if (!_id($value, $car_values)) {
                                return SYMBOL_NIL;
                            }
                        }
                    }
                    else {
                        push @stack, [map { prim_cdr($_) } @values];
                        push @stack, [map { prim_car($_) } @values];
                    }
                }

                $xs = prim_cdr($xs);
                $pat = prim_cdr($pat);
            }
        }

        return SYMBOL_T;
    },

    "caris" => sub {
        my ($call, $x, $y, $f) = @_;

        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        if (defined($f)) {
            return $call->($f, prim_car($x), $y);
        }
        else {
            my @stack = [prim_car($x), $y];
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
                        if (!_id($value, $car_values)) {
                            return SYMBOL_NIL;
                        }
                    }
                }
                else {
                    push @stack, [map { prim_cdr($_) } @values];
                    push @stack, [map { prim_car($_) } @values];
                }
            }

            return SYMBOL_T;
        }
    },

    "hug" => sub {
        my ($call, $xs, $f) = @_;

        my @values;
        my $cdr_xs;
        if (defined($f)) {
            while (!is_nil($cdr_xs = prim_cdr($xs))) {
                push @values, $call->($f, prim_car($xs), prim_car($cdr_xs));
                $xs = prim_cdr($cdr_xs);
            }
            if (!is_nil($xs)) {
                push @values, $call->($f, prim_car($xs));
            }
        }
        else {
            while (!is_nil($cdr_xs = prim_cdr($xs))) {
                push @values, make_pair(
                    prim_car($xs),
                    make_pair(
                        prim_car($cdr_xs),
                        SYMBOL_NIL));
                $xs = prim_cdr($cdr_xs);
            }
            if (!is_nil($xs)) {
                push @values, make_pair(prim_car($xs), SYMBOL_NIL);
            }
        }

        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    },

    "keep" => sub {
        my ($call, $f, $xs) = @_;

        my @values;
        while (!is_nil($xs)) {
            my $value = prim_car($xs);
            if (!is_nil($call->($f, $value))) {
                push @values, $value;
            }
            $xs = prim_cdr($xs);
        }

        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    },

    "rem" => sub {
        my ($call, $x, $ys, $f) = @_;

        my @values;
        if (defined($f)) {
            while (!is_nil($ys)) {
                my $value = prim_car($ys);
                if (is_nil($call->($f, $x, $value))) {
                    push @values, $value;
                }
                $ys = prim_cdr($ys);
            }
        }
        else {
            while (!is_nil($ys)) {
                my $value = prim_car($ys);
                my @stack = [$x, $value];
                while (@stack) {
                    my ($v0, $v1) = @{pop(@stack)};
                    if (!is_pair($v0) || !is_pair($v1)) {
                        if (!_id($v0, $v1)) {
                            push @values, $value;
                            last;
                        }
                    }
                    else {
                        push @stack, [prim_cdr($v0), prim_cdr($v1)];
                        push @stack, [prim_car($v0), prim_car($v1)];
                    }
                }
                $ys = prim_cdr($ys);
            }
        }

        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    },

    "get" => sub {
        my ($call, $k, $kvs, $f) = @_;

        if (defined($f)) {
            while (!is_nil($kvs)) {
                my $kv = prim_car($kvs);
                if (!is_nil($call->($f, prim_car($kv), $k))) {
                    return $kv;
                }
                $kvs = prim_cdr($kvs);
            }
        }
        else {
            ELEM:
            while (!is_nil($kvs)) {
                my $kv = prim_car($kvs);
                my @stack = [prim_car($kv), $k];
                while (@stack) {
                    my ($v0, $v1) = @{pop(@stack)};
                    if (!is_pair($v0) || !is_pair($v1)) {
                        if (!_id($v0, $v1)) {
                            $kvs = prim_cdr($kvs);
                            next ELEM;
                        }
                    }
                    else {
                        push @stack, [prim_cdr($v0), prim_cdr($v1)];
                        push @stack, [prim_car($v0), prim_car($v1)];
                    }
                }
                return $kv;
            }
        }

        return SYMBOL_NIL;
    },

    "where__get" => sub {
        my ($call, $k, $kvs, $f) = @_;

        if (defined($f)) {
            while (!is_nil($kvs)) {
                my $kv = prim_car($kvs);
                if (!is_nil($call->($f, prim_car($kv), $k))) {
                    return make_pair(
                        $kvs,
                        make_pair(
                            SYMBOL_A,
                            SYMBOL_NIL,
                        ),
                    );
                }
                $kvs = prim_cdr($kvs);
            }
        }
        else {
            ELEM:
            while (!is_nil($kvs)) {
                my $kv = prim_car($kvs);
                my @stack = [prim_car($kv), $k];
                while (@stack) {
                    my ($v0, $v1) = @{pop(@stack)};
                    if (!is_pair($v0) || !is_pair($v1)) {
                        if (!_id($v0, $v1)) {
                            $kvs = prim_cdr($kvs);
                            next ELEM;
                        }
                    }
                    else {
                        push @stack, [prim_cdr($v0), prim_cdr($v1)];
                        push @stack, [prim_car($v0), prim_car($v1)];
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
        }

        return SYMBOL_NIL;
    },

    "put" => sub {
        my ($call, $k, $v, $kvs, $f) = @_;

        my @values = make_pair($k, $v);
        if (defined($f)) {
            while (!is_nil($kvs)) {
                my $kv = prim_car($kvs);
                if (is_nil($call->($f, $k, prim_car($kv)))) {
                    push @values, $kv;
                }
                $kvs = prim_cdr($kvs);
            }
        }
        else {
            while (!is_nil($kvs)) {
                my $kv = prim_car($kvs);
                my @stack = [$k, prim_car($kv)];
                while (@stack) {
                    my ($v0, $v1) = @{pop(@stack)};
                    if (!is_pair($v0) || !is_pair($v1)) {
                        if (!_id($v0, $v1)) {
                            push @values, $kv;
                            last;
                        }
                    }
                    else {
                        push @stack, [prim_cdr($v0), prim_cdr($v1)];
                        push @stack, [prim_car($v0), prim_car($v1)];
                    }
                }
                $kvs = prim_cdr($kvs);
            }
        }

        my $result = SYMBOL_NIL;
        for my $value (reverse(@values)) {
            $result = make_pair($value, $result);
        }
        return $result;
    },

    "rev" => sub {
        my ($call, $xs) = @_;

        my $result = SYMBOL_NIL;
        while (!is_nil($xs)) {
            $result = make_pair(prim_car($xs), $result);
            $xs = prim_cdr($xs);
        }

        return $result;
    },

    "snap" => sub {
        my ($call, $xs, $ys, $acc) = @_;

        if (!defined($acc)) {
            $acc = SYMBOL_NIL;
        }

        my @values;
        while (!is_nil($acc)) {
            push @values, prim_car($acc);
            $acc = prim_cdr($acc);
        }

        while (!is_nil($xs)) {
            push @values, prim_car($ys);
            $xs = prim_cdr($xs);
            $ys = prim_cdr($ys);
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
    },

    "udrop" => sub {
        my ($call, $xs, $ys) = @_;

        while (!is_nil($xs)) {
            $xs = prim_cdr($xs);
            $ys = prim_cdr($ys);
        }

        return $ys;
    },

    "idfn" => sub {
        my ($call, $x) = @_;

        return $x;
    },

    "where__idfn" => sub {
        my ($call, $x) = @_;

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
    },

    "pairwise" => sub {
        my ($call, $f, $xs) = @_;

        my $cdr_xs;
        while (!is_nil($cdr_xs = prim_cdr($xs))) {
            if (is_nil($call->($f, prim_car($xs), prim_car($cdr_xs)))) {
                return SYMBOL_NIL;
            }
            $xs = $cdr_xs;
        }

        return SYMBOL_T;
    },

    "foldl" => sub {
        my ($call, $f, $base, @args) = @_;

        return $base
            unless @args;

        while (!grep { is_nil($_) } @args) {
            my @car_args = map { prim_car($_) } @args;
            $base = $call->($f, @car_args, $base);
            @args = map { prim_cdr($_) } @args;
        }

        return $base;
    },

    "foldr" => sub {
        my ($call, $f, $base, @args) = @_;

        return $base
            unless @args;

        my @cars;
        while (!grep { is_nil($_) } @args) {
            push @cars, [map { prim_car($_) } @args];
            @args = map { prim_cdr($_) } @args;
        }

        for my $cars (reverse(@cars)) {
            $base = $call->($f, @{$cars}, $base);
        }

        return $base;
    },

    "fuse" => sub {
        my ($call, $f, @args) = @_;

        return SYMBOL_NIL
            unless @args;
        my @sublists;
        my $min_length = -1;
        for my $list (@args) {
            my @sublist;
            while (!is_nil($list)) {
                push @sublist, prim_car($list);
                $list = prim_cdr($list);
            }
            push @sublists, \@sublist;
            my $length = scalar(@sublist);
            $min_length = $min_length == -1 || $length < $min_length
                ? $length
                : $min_length;
        }
        my @result;
        for my $i (0..$min_length-1) {
            push @result, $call->(
                $f,
                map { $sublists[$_]->[$i] } 0..$#sublists
            );
        }
        my $result = @result ? pop(@result) : SYMBOL_NIL;
        while (@result) {
            my $list = pop(@result);
            my @values;
            while (!is_nil($list)) {
                push @values, prim_car($list);
                $list = prim_cdr($list);
            }
            while (@values) {
                my $value = pop(@values);
                $result = make_pair($value, $result);
            }
        }

        return $result;
    },

    "match" => sub {
        my ($call, $x, $pat) = @_;

        my @stack = [$x, $pat];
        while (@stack) {
            my ($v0, $v1) = @{pop(@stack)};
            if (is_symbol_of_name($v1, "t")) {
                # succeed
            }
            elsif (is_pair($v1)
                && is_symbol_of_name(prim_car($v1), "lit")
                && is_pair(prim_cdr($v1))
                && (is_symbol_of_name(prim_car(prim_cdr($v1)), "prim")
                    || is_symbol_of_name(prim_car(prim_cdr($v1)), "clo"))) {
                if (is_nil($call->($v1, $v0))) {
                    return SYMBOL_NIL;
                }
            }
            elsif (!is_pair($v0) || !is_pair($v1)) {
                if (!_id($v0, $v1)) {
                    return SYMBOL_NIL;
                }
            }
            else {
                push @stack, [prim_cdr($v0), prim_cdr($v1)];
                push @stack, [prim_car($v0), prim_car($v1)];
            }
        }

        return SYMBOL_T;
    },

    "split" => sub {
        my ($call, $f, $xs, $acc) = @_;

        if (!defined($acc)) {
            $acc = SYMBOL_NIL;
        }
        my @acc;
        while (!is_nil($xs)) {
            last
                if !is_pair($xs) || !is_nil($call->($f, prim_car($xs)));
            push(@acc, prim_car($xs));
            $xs = prim_cdr($xs);
        }

        my @prefix;
        while (!is_nil($acc)) {
            push(@prefix, prim_car($acc));
            $acc = prim_cdr($acc);
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
    },

    "i<" => sub {
        my ($call, $xs, $ys) = @_;

        while (!is_nil($xs)) {
            $xs = prim_cdr($xs);
            $ys = prim_cdr($ys);
        }

        return $ys;
    },

    "i+" => sub {
        my ($call, @args) = @_;

        my $result = @args ? pop(@args) : SYMBOL_NIL;
        while (@args) {
            my $list = pop(@args);
            my @values;
            while (!is_nil($list)) {
                push @values, prim_car($list);
                $list = prim_cdr($list);
            }
            while (@values) {
                my $value = pop(@values);
                $result = make_pair($value, $result);
            }
        }

        return $result;
    },

    "i-" => sub {
        my ($call, $x, $y) = @_;

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

            $x = prim_cdr($x);
            $y = prim_cdr($y);
        }

        return make_pair(
            make_symbol("-"),
            make_pair(
                $y,
                SYMBOL_NIL,
            ),
        );
    },

    "i*" => sub {
        my ($call, @args) = @_;

        my $product = 1;
        for my $arg (@args) {
            my $factor = 0;
            while (!is_nil($arg)) {
                $factor += 1;
                $arg = prim_cdr($arg);
            }
            $product *= $factor;
        }

        my $result = SYMBOL_NIL;
        for (1..$product) {
            $result = make_pair(SYMBOL_T, $result);
        }
        return $result;
    },

    "i/" => sub {
        my ($call, $x, $y, $q) = @_;

        if (!defined($q)) {
            $q = SYMBOL_NIL;
        }

        my $xn = 0;
        while (!is_nil($x)) {
            $xn += 1;
            $x = prim_cdr($x);
        }

        my $yn = 0;
        while (!is_nil($y)) {
            $yn += 1;
            $y = prim_cdr($y);
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
    },

    "i^" => sub {
        my ($call, $x, $y) = @_;

        my $xn = 0;
        while (!is_nil($x)) {
            $xn += 1;
            $x = prim_cdr($x);
        }

        my $yn = 0;
        while (!is_nil($y)) {
            $yn += 1;
            $y = prim_cdr($y);
        }

        my $n = $xn ** $yn;

        my $result = SYMBOL_NIL;
        for (1..$n) {
            $result = make_pair(SYMBOL_T, $result);
        }
        return $result;
    },

    "r+" => sub {
        my ($call, $x, $y) = @_;

        my $xn = prim_car($x);
        my $xd = prim_car(prim_cdr($x));

        my $yn = prim_car($y);
        my $yd = prim_car(prim_cdr($y));

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = prim_cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = prim_cdr($xd);
        }

        my $yn_n = 0;
        while (!is_nil($yn)) {
            ++$yn_n;
            $yn = prim_cdr($yn);
        }

        my $yd_n = 0;
        while (!is_nil($yd)) {
            ++$yd_n;
            $yd = prim_cdr($yd);
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
    },

    "r-" => sub {
        my ($call, $x, $y) = @_;

        my $xn = prim_car($x);
        my $xd = prim_car(prim_cdr($x));

        my $yn = prim_car($y);
        my $yd = prim_car(prim_cdr($y));

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = prim_cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = prim_cdr($xd);
        }

        my $yn_n = 0;
        while (!is_nil($yn)) {
            ++$yn_n;
            $yn = prim_cdr($yn);
        }

        my $yd_n = 0;
        while (!is_nil($yd)) {
            ++$yd_n;
            $yd = prim_cdr($yd);
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
    },

    "prn" => sub {
        my ($call, @args) = @_;

        my $last = SYMBOL_NIL;
        for (@args) {
            print(Language::Bel::Printer::_print($_));
            print(" ");
            $last = $_;
        }
        print("\n");
        return $last;
    },

    "pr" => sub {
        my ($call, @args) = @_;

        print for
            map { Language::Bel::Printer::prnice($_) }
            @args;

        my $result = SYMBOL_NIL;
        while (@args) {
            $result = make_pair(pop(@args), $result);
        }
        return $result;
    },

    "prs" => sub {
        my ($call, @args) = @_;

        my @strings;
        for (@args) {
            push(@strings, Language::Bel::Printer::prnice($_));
        }

        my $result = SYMBOL_NIL;
        while (@strings) {
            my $string = pop(@strings);
            for my $char (reverse(split //, $string)) {
                my $c = make_char(ord($char));
                $result = make_pair($c, $result);
            }
        }
        return $result;
    },

    "r*" => sub {
        my ($call, $x, $y) = @_;

        my $xn = prim_car($x);
        my $xd = prim_car(prim_cdr($x));

        my $yn = prim_car($y);
        my $yd = prim_car(prim_cdr($y));

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = prim_cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = prim_cdr($xd);
        }

        my $yn_n = 0;
        while (!is_nil($yn)) {
            ++$yn_n;
            $yn = prim_cdr($yn);
        }

        my $yd_n = 0;
        while (!is_nil($yd)) {
            ++$yd_n;
            $yd = prim_cdr($yd);
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
    },

    "r/" => sub {
        my ($call, $x, $y) = @_;

        my $xn = prim_car($x);
        my $xd = prim_car(prim_cdr($x));

        my $yn = prim_car($y);
        my $yd = prim_car(prim_cdr($y));

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = prim_cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = prim_cdr($xd);
        }

        my $yn_n = 0;
        while (!is_nil($yn)) {
            ++$yn_n;
            $yn = prim_cdr($yn);
        }

        my $yd_n = 0;
        while (!is_nil($yd)) {
            ++$yd_n;
            $yd = prim_cdr($yd);
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
    },

    "sr+" => sub {
        my ($call, $x, $y) = @_;

        my $xs = prim_car($x);
        my $xn = prim_car(prim_cdr($x));
        my $xd = prim_car(prim_cdr(prim_cdr($x)));

        my $ys = prim_car($y);
        my $yn = prim_car(prim_cdr($y));
        my $yd = prim_car(prim_cdr(prim_cdr($y)));

        my $symbol;
        if (is_symbol_of_name($xs, "-")) {
            if (is_symbol_of_name($ys, "-")) {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
    },

    "sr-" => sub {
        my ($call, $x, $y) = @_;

        my $xs = prim_car($x);
        my $xn = prim_car(prim_cdr($x));
        my $xd = prim_car(prim_cdr(prim_cdr($x)));

        my $ys = prim_car($y);
        my $yn = prim_car(prim_cdr($y));
        my $yd = prim_car(prim_cdr(prim_cdr($y)));

        my $symbol;
        if (is_symbol_of_name($xs, "-")) {
            if (is_symbol_of_name($ys, "-")) {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
    },

    "srinv" => sub {
        my ($call, $sr) = @_;

        my $s = prim_car($sr);
        my $n = prim_car(prim_cdr($sr));
        my $d = prim_car(prim_cdr(prim_cdr($sr)));

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
    },

    "sr*" => sub {
        my ($call, $x, $y) = @_;

        my $xs = prim_car($x);
        my $xn = prim_car(prim_cdr($x));
        my $xd = prim_car(prim_cdr(prim_cdr($x)));

        my $ys = prim_car($y);
        my $yn = prim_car(prim_cdr($y));
        my $yd = prim_car(prim_cdr(prim_cdr($y)));

        my $sign = is_symbol_of_name($xs, "-")
            ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
            : $ys;

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = prim_cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = prim_cdr($xd);
        }

        my $yn_n = 0;
        while (!is_nil($yn)) {
            ++$yn_n;
            $yn = prim_cdr($yn);
        }

        my $yd_n = 0;
        while (!is_nil($yd)) {
            ++$yd_n;
            $yd = prim_cdr($yd);
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
    },

    "sr/" => sub {
        my ($call, $x, $y) = @_;

        my $xs = prim_car($x);
        my $xn = prim_car(prim_cdr($x));
        my $xd = prim_car(prim_cdr(prim_cdr($x)));

        my $ys = prim_car($y);
        my $yn = prim_car(prim_cdr($y));
        my $yd = prim_car(prim_cdr(prim_cdr($y)));

        die "'mistype\n"
            if is_nil($yn);

        my $sign = is_symbol_of_name($xs, "-")
            ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
            : $ys;

        my $xn_n = 0;
        while (!is_nil($xn)) {
            ++$xn_n;
            $xn = prim_cdr($xn);
        }

        my $xd_n = 0;
        while (!is_nil($xd)) {
            ++$xd_n;
            $xd = prim_cdr($xd);
        }

        my $yn_n = 0;
        while (!is_nil($yn)) {
            ++$yn_n;
            $yn = prim_cdr($yn);
        }

        my $yd_n = 0;
        while (!is_nil($yd)) {
            ++$yd_n;
            $yd = prim_cdr($yd);
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
    },

    "srrecip" => sub {
        my ($call, $sr) = @_;

        my $s = prim_car($sr);
        my $n = prim_car(prim_cdr($sr));
        die "'mistype\n"
            if is_nil($n);
        my $d = prim_car(prim_cdr(prim_cdr($sr)));

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
    },

    "sr<" => sub {
        my ($call, $x, $y) = @_;

        my $xs = prim_car($x);
        my $xn = prim_car(prim_cdr($x));
        my $xd = prim_car(prim_cdr(prim_cdr($x)));

        my $ys = prim_car($y);
        my $yn = prim_car(prim_cdr($y));
        my $yd = prim_car(prim_cdr(prim_cdr($y)));

        if (is_symbol_of_name($xs, "+")) {
            if (is_symbol_of_name($ys, "+")) {
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                    $xn = prim_cdr($xn);
                }

                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }

                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }

                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
    },

    "srnum" => sub {
        my ($call, $x) = @_;

        return prim_car(prim_cdr($x));
    },

    "where__srnum" => sub {
        my ($call, $x) = @_;

        return make_pair(
            prim_cdr($x),
            make_pair(
                SYMBOL_A,
                SYMBOL_NIL,
            ),
        );
    },

    "srden" => sub {
        my ($call, $x) = @_;

        return prim_car(prim_cdr(prim_cdr($x)));
    },

    "where__srden" => sub {
        my ($call, $x) = @_;

        return make_pair(
            prim_cdr(prim_cdr($x)),
            make_pair(
                SYMBOL_A,
                SYMBOL_NIL,
            ),
        );
    },

    "c+" => sub {
        my ($call, $x, $y) = @_;

        my $xr = prim_car($x);
        my $xi = prim_car(prim_cdr($x));

        my $yr = prim_car($y);
        my $yi = prim_car(prim_cdr($y));

        my $real_part;
        {
            my $xs = prim_car($xr);
            my $xn = prim_car(prim_cdr($xr));
            my $xd = prim_car(prim_cdr(prim_cdr($xr)));

            my $ys = prim_car($yr);
            my $yn = prim_car(prim_cdr($yr));
            my $yd = prim_car(prim_cdr(prim_cdr($yr)));

            my $symbol;
            if (is_symbol_of_name($xs, "-")) {
                if (is_symbol_of_name($ys, "-")) {
                    my $xn_n = 0;
                    while (!is_nil($xn)) {
                        ++$xn_n;
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
            my $xs = prim_car($xi);
            my $xn = prim_car(prim_cdr($xi));
            my $xd = prim_car(prim_cdr(prim_cdr($xi)));

            my $ys = prim_car($yi);
            my $yn = prim_car(prim_cdr($yi));
            my $yd = prim_car(prim_cdr(prim_cdr($yi)));

            my $symbol;
            if (is_symbol_of_name($xs, "-")) {
                if (is_symbol_of_name($ys, "-")) {
                    my $xn_n = 0;
                    while (!is_nil($xn)) {
                        ++$xn_n;
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
                        $xn = prim_cdr($xn);
                    }

                    my $xd_n = 0;
                    while (!is_nil($xd)) {
                        ++$xd_n;
                        $xd = prim_cdr($xd);
                    }

                    my $yn_n = 0;
                    while (!is_nil($yn)) {
                        ++$yn_n;
                        $yn = prim_cdr($yn);
                    }

                    my $yd_n = 0;
                    while (!is_nil($yd)) {
                        ++$yd_n;
                        $yd = prim_cdr($yd);
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
    },

    "c*" => sub {
        my ($call, $x, $y) = @_;
        
        my $xr = prim_car($x);
        my $xi = prim_car(prim_cdr($x));
        
        my $yr = prim_car($y);
        my $yi = prim_car(prim_cdr($y));
        
        my $real_part;
        {
            my $term1s;
            my $term1n_n;
            my $term1d_n;
            
            {
                my $xs = prim_car($xr);
                my $xn = prim_car(prim_cdr($xr));
                my $xd = prim_car(prim_cdr(prim_cdr($xr)));
            
                my $ys = prim_car($yr);
                my $yn = prim_car(prim_cdr($yr));
                my $yd = prim_car(prim_cdr(prim_cdr($yr)));
            
                $term1s = is_symbol_of_name($xs, "-")
                    ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                    : $ys;
            
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = prim_cdr($xn);
                }
            
                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }
            
                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }
            
                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
                }
            
                $term1n_n = $xn_n * $yn_n;
                $term1d_n = $xd_n * $yd_n;
            }
        
            my $term2s;
            my $term2n_n;
            my $term2d_n;
            
            {
                my $xs = prim_car($xi);
                my $xn = prim_car(prim_cdr($xi));
                my $xd = prim_car(prim_cdr(prim_cdr($xi)));
            
                my $ys = prim_car($yi);
                my $yn = prim_car(prim_cdr($yi));
                my $yd = prim_car(prim_cdr(prim_cdr($yi)));
            
                $term2s = is_symbol_of_name($xs, "-")
                    ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                    : $ys;
            
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = prim_cdr($xn);
                }
            
                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }
            
                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }
            
                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
                my $xs = prim_car($xi);
                my $xn = prim_car(prim_cdr($xi));
                my $xd = prim_car(prim_cdr(prim_cdr($xi)));
            
                my $ys = prim_car($yr);
                my $yn = prim_car(prim_cdr($yr));
                my $yd = prim_car(prim_cdr(prim_cdr($yr)));
            
                $term1s = is_symbol_of_name($xs, "-")
                    ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                    : $ys;
            
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = prim_cdr($xn);
                }
            
                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }
            
                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }
            
                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
                }
            
                $term1n_n = $xn_n * $yn_n;
                $term1d_n = $xd_n * $yd_n;
            }
        
            my $term2s;
            my $term2n_n;
            my $term2d_n;
            
            {
                my $xs = prim_car($xr);
                my $xn = prim_car(prim_cdr($xr));
                my $xd = prim_car(prim_cdr(prim_cdr($xr)));
            
                my $ys = prim_car($yi);
                my $yn = prim_car(prim_cdr($yi));
                my $yd = prim_car(prim_cdr(prim_cdr($yi)));
            
                $term2s = is_symbol_of_name($xs, "-")
                    ? make_symbol(is_symbol_of_name($ys, "-") ? "+" : "-")
                    : $ys;
            
                my $xn_n = 0;
                while (!is_nil($xn)) {
                    ++$xn_n;
                    $xn = prim_cdr($xn);
                }
            
                my $xd_n = 0;
                while (!is_nil($xd)) {
                    ++$xd_n;
                    $xd = prim_cdr($xd);
                }
            
                my $yn_n = 0;
                while (!is_nil($yn)) {
                    ++$yn_n;
                    $yn = prim_cdr($yn);
                }
            
                my $yd_n = 0;
                while (!is_nil($yd)) {
                    ++$yd_n;
                    $yd = prim_cdr($yd);
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
    },

    "litnum" => sub {
        my ($call, $r, $i) = @_;

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
    },

    "number" => sub {
        my ($call, $x) = @_;

        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        if (!is_symbol_of_name(prim_car($x), "lit")) {
            return SYMBOL_NIL;
        }

        $x = prim_cdr($x);
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        if (!is_symbol_of_name(prim_car($x), "num")) {
            return SYMBOL_NIL;
        }

        $x = prim_cdr($x);
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        {
            my $y = prim_car($x);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }


            my $sign = prim_car($y);
            if (!(is_symbol_of_name($sign, "+") || is_symbol_of_name($sign, "-"))) {
                return SYMBOL_NIL;
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            {
                my $z = prim_car($y);
                while (!is_nil($z)) {
                    if (!is_pair($z)) {
                        return SYMBOL_NIL;
                    }
                    $z = prim_cdr($z);
                }
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            {
                my $z = prim_car($y);
                while (!is_nil($z)) {
                    if (!is_pair($z)) {
                        return SYMBOL_NIL;
                    }
                    $z = prim_cdr($z);
                }
            }
        }

        $x = prim_cdr($x);
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        {
            my $y = prim_car($x);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }


            my $sign = prim_car($y);
            if (!(is_symbol_of_name($sign, "+") || is_symbol_of_name($sign, "-"))) {
                return SYMBOL_NIL;
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            {
                my $z = prim_car($y);
                while (!is_nil($z)) {
                    if (!is_pair($z)) {
                        return SYMBOL_NIL;
                    }
                    $z = prim_cdr($z);
                }
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            {
                my $z = prim_car($y);
                while (!is_nil($z)) {
                    if (!is_pair($z)) {
                        return SYMBOL_NIL;
                    }
                    $z = prim_cdr($z);
                }
            }
        }

        return SYMBOL_T;
    },

    "numr" => sub {
        my ($call, $x) = @_;

        return prim_car(prim_cdr(prim_cdr($x)));
    },

    "numi" => sub {
        my ($call, $x) = @_;

        return prim_car(prim_cdr(prim_cdr(prim_cdr($x))));
    },

    "rpart" => sub {
        my ($call, $n) = @_;

        my $numr = prim_car(prim_cdr(prim_cdr($n)));

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
    },

    "ipart" => sub {
        my ($call, $n) = @_;

        my $numi = prim_car(prim_cdr(prim_cdr(prim_cdr($n))));

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
    },

    "real" => sub {
        my ($call, $x) = @_;

        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        if (!is_symbol_of_name(prim_car($x), "lit")) {
            return SYMBOL_NIL;
        }

        $x = prim_cdr($x);
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        if (!is_symbol_of_name(prim_car($x), "num")) {
            return SYMBOL_NIL;
        }

        $x = prim_cdr($x);
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        {
            my $y = prim_car($x);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }


            my $sign = prim_car($y);
            if (!(is_symbol_of_name($sign, "+") || is_symbol_of_name($sign, "-"))) {
                return SYMBOL_NIL;
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            {
                my $z = prim_car($y);
                while (!is_nil($z)) {
                    if (!is_pair($z)) {
                        return SYMBOL_NIL;
                    }
                    $z = prim_cdr($z);
                }
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            {
                my $z = prim_car($y);
                while (!is_nil($z)) {
                    if (!is_pair($z)) {
                        return SYMBOL_NIL;
                    }
                    $z = prim_cdr($z);
                }
            }
        }

        $x = prim_cdr($x);
        if (!is_pair($x)) {
            return SYMBOL_NIL;
        }

        {
            my $y = prim_car($x);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }


            my $sign = prim_car($y);
            if (!is_symbol_of_name($sign, "+")) {
                return SYMBOL_NIL;
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            if (!is_nil(prim_car($y))) {
                return SYMBOL_NIL;
            }

            $y = prim_cdr($y);
            if (!is_pair($y)) {
                return SYMBOL_NIL;
            }

            {
                my $z = prim_car($y);
                my $t = 0;
                while (!is_nil($z)) {
                    if (!is_pair($z)) {
                        return SYMBOL_NIL;
                    }
                    $z = prim_cdr($z);
                    $t++;
                }

                if ($t != 1) {
                    return SYMBOL_NIL;
                }
            }
        }

        return SYMBOL_T;
    },
);

sub FASTFUNCS {
    return \%FASTFUNCS;
}

our @EXPORT_OK = qw(
    FASTFUNCS
);

1;
