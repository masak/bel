package Language::Bel::Printer;

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    char_codepoint
    is_char
    is_nil
    is_pair
    is_stream
    is_string
    is_symbol
    is_symbol_of_name
    pair_car
    pair_cdr
    string_value
    symbol_name
);

use Exporter 'import';

my %codepoint_chars = (
    7 => "bel",
    9 => "tab",
    10 => "lf",
    13 => "cr",
    32 => "sp",
);

sub _print {
    my ($ast, $names_ref, $hist_ref) = @_;

    if (!defined($names_ref)) {
        $names_ref = namedups($ast);
    }
    if (!defined($hist_ref)) {
        $hist_ref = {};
    }

    my $string_escape = sub {
        my ($string) = @_;

        return join("", map {
            $_ eq q["] || $_ eq q[\\] ? "\\$_" : $_
        } split("", $string));
    };

    my $r_i;
    if (is_symbol($ast)) {
        my $name = symbol_name($ast);
        return $name;
    }
    elsif (is_char($ast)) {
        my $codepoint = char_codepoint($ast);
        my $name = $codepoint_chars{$codepoint};
        return $name
            ? "\\$name"
            : "\\" . chr($codepoint);
    }
    elsif (is_string($ast)) {
        my $string = string_value($ast);
        return q["] . $string_escape->($string) . q["];
    }
    elsif ($r_i = is_number($ast)) {
        my $r = $r_i->[0];
        my $i = $r_i->[1];
        return prnum($r, $i);
    }
    elsif (is_stream($ast)) {
        return "<stream>";
    }
    elsif (is_pair($ast)) {
        my @fragments;
        if (my $n = $names_ref->{$ast}) {
            push @fragments, "#", $n;

            if ($hist_ref->{$ast}++) {
                return join("", @fragments);
            }
            else {
                push @fragments, "=";
                # continue printing after this `if` statement
            }
        }

        push @fragments, "(";
        my $first_elem = 1;
        while (is_pair($ast) && !is_number($ast)) {
            if (!$first_elem) {
                push @fragments, " ";
            }
            push @fragments, _print(pair_car($ast), $names_ref, $hist_ref);
            $ast = pair_cdr($ast);
            last if $names_ref->{$ast};
            $first_elem = "";
        }
        if (!is_nil($ast)) {
            push @fragments, " . ";
            push @fragments, _print($ast, $names_ref, $hist_ref);
        }
        push @fragments, ")";
        return join("", @fragments);
    }
    else {
        die "unhandled: unknown thing to print";
    }
}

sub prnice {
    my ($ast) = @_;

    my $r_i;
    if (is_symbol($ast)) {
        my $name = symbol_name($ast);
        return $name;
    }
    elsif (is_char($ast)) {
        my $codepoint = char_codepoint($ast);
        return chr($codepoint);
    }
    elsif (is_string($ast)) {
        return string_value($ast);
    }
    elsif ($r_i = is_number($ast)) {
        my $r = $r_i->[0];
        my $i = $r_i->[1];
        return prnum($r, $i);
    }
    elsif (is_pair($ast)) {
        my @fragments = ("(");
        my $first_elem = 1;
        while (is_pair($ast) && !is_number($ast)) {
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
        die "unhandled: unknown thing to print";
    }
}

# (def number (x)
#   (let r (fn (y)
#            (match y (list [in _ '+ '-] proper proper)))
#     (match x `(lit num ,r ,r))))
sub is_number {
    my ($x) = @_;

    my $proper = sub {
        my ($z) = @_;
        while (is_pair($z)) {
            $z = pair_cdr($z);
        }
        return is_nil($z);
    };

    my $sr = sub {
        my ($y) = @_;
        my ($sign, $y1, $y2);
        return is_pair($y)
            && (is_symbol_of_name(($sign = pair_car($y)), "+")
                || is_symbol_of_name($sign, "-"))
            && is_pair($y1 = pair_cdr($y))
            && $proper->(pair_car($y1))
            && is_pair($y2 = pair_cdr($y1))
            && $proper->(pair_car($y2));
    };

    my ($x1, $x2, $x3, $r, $i);
    return is_pair($x)
        && is_symbol_of_name(pair_car($x), "lit")
        && is_pair($x1 = pair_cdr($x))
        && is_symbol_of_name(pair_car($x1), "num")
        && is_pair($x2 = pair_cdr($x1))
        && $sr->($r = pair_car($x2))
        && is_pair($x3 = pair_cdr($x2))
        && $sr->($i = pair_car($x3))
        && is_nil(pair_cdr($x3))
        && [$r, $i];
}

# (def prnum (r i s)
#   (unless (and (= r srzero) (~= i srzero))
#     (if (caris r '-) (prc \- s))
#     (map [prc _ s] (rrep (cdr r))))
#   (unless (= i srzero)
#     (print (car i) s)
#     (unless (apply = (cdr i))
#       (map [prc _ s] (rrep (cdr i))))
#     (prc \i s)))
#
# (def rrep ((n d) (o base i10))
#   (append (irep n base)
#           (if (= d i1) nil (cons \/ (irep d base)))))
#
# (def irep (x base)
#   (if (i< x base)
#       (list (intchar x))
#       (let (q r) (i/ x base)
#         (snoc (irep q base) (intchar r)))))
sub prnum {
    my ($r, $i) = @_;

    my $is_zero = sub {
        my ($sr) = @_;

        my $n = pair_car(pair_cdr($sr));
        return is_symbol_of_name($n, "nil");
    };

    my $eq_i1 = sub {
        my ($i) = @_;

        return is_pair($i) && is_nil(pair_cdr($i));
    };

    my $equal = sub {
        my ($i1, $i2) = @_;

        while (is_pair($i1) && is_pair($i2)) {
            $i1 = pair_cdr($i1);
            $i2 = pair_cdr($i2);
        }
        return is_nil($i1) && is_nil($i2);
    };

    my $irep = sub {
        my ($x) = @_;
        my $result = 0;
        while (is_pair($x)) {
            $result += 1;
            $x = pair_cdr($x);
        }
        return $result;
    };

    my $rrep = sub {
        my ($n, $d) = @_;

        return $eq_i1->($d)
            ? $irep->($n)
            : ($irep->($n), "/", $irep->($d));
    };

    my @result;
    if (!$is_zero->($r) || $is_zero->($i)) {
        my $r_sign = pair_car($r);
        if (symbol_name($r_sign) eq "-") {
            push @result, "-";
        }
        my $r_rest = pair_cdr($r);
        my $r_n = pair_car($r_rest);
        my $r_d = pair_car(pair_cdr($r_rest));
        push @result, $rrep->($r_n, $r_d);
    }
    if (!$is_zero->($i)) {
        my $i_sign = pair_car($i);
        push @result, symbol_name($i_sign);
        my $i_rest = pair_cdr($i);
        my $i_n = pair_car($i_rest);
        my $i_d = pair_car(pair_cdr($i_rest));
        if (!$equal->($i_n, $i_d)) {
            push @result, $rrep->($i_n, $i_d);
        }
        push @result, "i";
    }
    return join "", @result;
}

# (def namedups (x (o n 0))
#   (map [cons _ (++ n)] (dups (cells x) id)))
sub namedups {
    my ($x) = @_;

    my $n = 0;
    my %dups;
    for my $dup (dups_id(cells($x))) {
        $dups{$dup} = ++$n;
    }
    return \%dups;
}

# (def cells (x (o seen))
#   (if (simple x)      seen
#       (mem x seen id) (snoc seen x)
#                       (cells (cdr x)
#                              (cells (car x) (snoc seen x)))))
sub cells {
    my ($x, $seen_ref) = @_;

    if (!defined($seen_ref)) {
        $seen_ref = {
            array => [],
            hash => {},
        };
    }

    if (is_simple($x)) {
        return $seen_ref;
    }
    # at this point we know it's a pair
    else {
        push @{$seen_ref->{array}}, $x;
        if (!$seen_ref->{hash}->{$x}++) {
            cells(pair_car($x), $seen_ref);
            cells(pair_cdr($x), $seen_ref);
        }
        return $seen_ref;
    }
}

# (def dups (xs (o f =))
#   (if (no xs)                   nil
#       (mem (car xs) (cdr xs) f) (cons (car xs)
#                                       (dups (rem (car xs) (cdr xs) f) f))
#                                 (dups (cdr xs) f)))
sub dups_id {
    my ($xs_ref) = @_;
    my $xs_arrayref = $xs_ref->{array};

    my @result;
    my %seen;
    my $length = scalar(@{$xs_arrayref});
    for my $i (0 .. ($length - 1)) {
        my $x = $xs_arrayref->[$i];
        next if $seen{$x}++;

        for my $j (($i + 1) .. ($length - 1)) {
            my $y = $xs_arrayref->[$j];
            if ($x == $y) {
                push @result, $x;
                last;
            }
        }
    }
    return @result;
}

# (set simple (cor atom number))
sub is_simple {
    my ($x) = @_;

    return !is_pair($x) || is_number($x);
}

our @EXPORT_OK = qw(
    _print
    prnice
);

1;
