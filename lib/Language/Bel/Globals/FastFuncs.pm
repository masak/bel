package Language::Bel::Globals::FastFuncs;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_char
    is_nil
    is_pair
    is_symbol
    make_pair
);
use Language::Bel::Primitives qw(
    _id
    prim_car
    prim_cdr
    prim_id
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
    SYMBOL_T
);

use Exporter 'import';

my %FASTFUNCS = (
    "no" => sub {
        my ($interpreter, $x) = @_;

        return is_nil($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "atom" => sub {
        my ($interpreter, $x) = @_;

        return is_pair($x) ? SYMBOL_NIL : SYMBOL_T;
    },

    "all" => sub {
        my ($interpreter, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $p = $interpreter->run_function_and_return($f, prim_car($xs));
            if (is_nil($p)) {
                return SYMBOL_NIL;
            }
            $xs = prim_cdr($xs);
        }

        return SYMBOL_T;
    },

    "some" => sub {
        my ($interpreter, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $p = $interpreter->run_function_and_return($f, prim_car($xs));
            if (!is_nil($p)) {
                return $xs;
            }
            $xs = prim_cdr($xs);
        }

        return SYMBOL_NIL;
    },

    "reduce" => sub {
        my ($interpreter, $f, $xs) = @_;

        my @values;
        while (!is_nil($xs)) {
            push @values, prim_car($xs);
            $xs = prim_cdr($xs);
        }

        my $result = @values ? pop(@values) : SYMBOL_NIL;
        while (@values) {
            my $value = pop(@values);
            $result = $interpreter->run_function_and_return($f, $value, $result);
        }

        return $result;
    },

    "cons" => sub {
        my ($interpreter, @args) = @_;

        my $result = @args ? pop(@args) : SYMBOL_NIL;
        while (@args) {
            my $value = pop(@args);
            $result = make_pair($value, $result);
        }

        return $result;
    },

    "append" => sub {
        my ($interpreter, @args) = @_;

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
        my ($interpreter, @args) = @_;

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
        my ($interpreter, @args) = @_;

        my $result = SYMBOL_NIL;
        while (@args) {
            my $value = pop(@args);
            $result = make_pair($value, $result);
        }

        return $result;
    },

    "map" => sub {
        my ($interpreter, $f, @ls) = @_;

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
            push @result, $interpreter->run_function_and_return(
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
        my ($interpreter, @args) = @_;

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
        my ($interpreter, $x) = @_;

        return is_symbol($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "pair" => sub {
        my ($interpreter, $x) = @_;

        return is_pair($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "char" => sub {
        my ($interpreter, $x) = @_;

        return is_char($x) ? SYMBOL_T : SYMBOL_NIL;
    },

    "proper" => sub {
        my ($interpreter, $x) = @_;

        while (!is_nil($x)) {
            if (!is_pair($x)) {
                return SYMBOL_NIL;
            }
            $x = prim_cdr($x);
        }

        return SYMBOL_T;
    },

    "string" => sub {
        my ($interpreter, $x) = @_;

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
        my ($interpreter, $x, $ys, $f) = @_;

        while (!is_nil($ys)) {
            my $p;
            if (defined($f)) {
                $p = $interpreter->run_function_and_return($f, prim_car($ys), $x);
            }
            else {
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
                                $p = SYMBOL_NIL;
                                goto COMPARED;
                            }
                        }
                    }
                    else {
                        push @stack, [map { prim_cdr($_) } @values];
                        push @stack, [map { prim_car($_) } @values];
                    }
                }

                $p = SYMBOL_T;
            }
            COMPARED:
            if (!is_nil($p)) {
                return $ys;
            }
            $ys = prim_cdr($ys);
        }

        return SYMBOL_NIL;
    },

    "in" => sub {
        my ($interpreter, @args) = @_;

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

    "cadr" => sub {
        my ($interpreter, $x) = @_;

        return prim_car(prim_cdr($x));
    },

    "cddr" => sub {
        my ($interpreter, $x) = @_;

        return prim_cdr(prim_cdr($x));
    },

    "caddr" => sub {
        my ($interpreter, $x) = @_;

        return prim_car(prim_cdr(prim_cdr($x)));
    },

    "find" => sub {
        my ($interpreter, $f, $xs) = @_;

        while (!is_nil($xs)) {
            my $value = prim_car($xs);
            if (!is_nil($interpreter->run_function_and_return($f, $value))) {
                return $value;
            }
            $xs = prim_cdr($xs);
        }
        return SYMBOL_NIL;
    },
);

sub FASTFUNCS {
    return \%FASTFUNCS;
}

our @EXPORT_OK = qw(
    FASTFUNCS
);

1;
