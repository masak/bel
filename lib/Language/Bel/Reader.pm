package Language::Bel::Reader;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    make_char
    make_pair
    make_symbol
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_BQUOTE
    SYMBOL_COMMA
    SYMBOL_COMMA_AT
    SYMBOL_NIL
    SYMBOL_QUOTE
    SYMBOL_T
);
use Exporter 'import';

sub _read {
    my ($expr) = @_;

    return _read_helper($expr, 0)->{ast};
}

sub _read_helper {
    my ($expr, $pos) = @_;

    my $skip_whitespace = sub {
        while ($pos < length($expr) && substr($expr, $pos, 1) =~ /\s/) {
            ++$pos;
        }
    };

    $skip_whitespace->();
    return { ast => SYMBOL_NIL, pos => $pos }
        if $pos >= length($expr);

    my $c = substr($expr, $pos, 1);
    if ($c eq "(") {
        return _rdlist($expr, ")", $pos);
    }
    elsif ($c eq "[") {
        my $r = _rdlist($expr, "]", $pos);
        return { ast => wrap_in_fn($r->{ast}), pos => $r->{pos} };
    }
    elsif ($c eq "'") {
        ++$pos;
        my $r = _read_helper($expr, $pos);
        my $ast = make_pair(SYMBOL_QUOTE, make_pair($r->{ast}, SYMBOL_NIL));
        return { ast => $ast, pos => $r->{pos} };
    }
    elsif ($c eq "`") {
        ++$pos;
        my $r = _read_helper($expr, $pos);
        my $ast = make_pair(SYMBOL_BQUOTE, make_pair($r->{ast}, SYMBOL_NIL));
        return { ast => $ast, pos => $r->{pos} };
    }
    elsif ($c eq ",") {
        ++$pos;
        my $symbol = SYMBOL_COMMA;
        my $cc = substr($expr, $pos, 1);
        if ($cc eq "@") {
            ++$pos;
            $symbol = SYMBOL_COMMA_AT;
        }
        my $r = _read_helper($expr, $pos);
        my $ast = make_pair($symbol, make_pair($r->{ast}, SYMBOL_NIL));
        return { ast => $ast, pos => $r->{pos} };
    }
    elsif ($c eq "\\") {
        ++$pos;
        my $start = $pos;
        EAT_CHAR:
        {
            do {
                my $cc = substr($expr, $pos, 1);
                # XXX: cheat for now
                last EAT_CHAR if $cc eq ")" or $cc eq "]" or $cc =~ /\s/;
                ++$pos;
            } while ($pos < length($expr));
        }
        my $ast = make_char(substr($expr, $start, $pos - $start));
        return { ast => $ast, pos => $pos };
    }
    elsif ($c eq q["]) {
        ++$pos;
        my @chars;
        EAT_CHAR:
        {
            do {
                my $cc = substr($expr, $pos, 1);
                ++$pos;
                last EAT_CHAR if $cc eq q["];
                if ($cc eq q[\\]) {
                    $cc = substr($expr, $pos, 1);
                    ++$pos;
                }
                push @chars, $cc;
            } while ($pos < length($expr));
        }
        my $ast = SYMBOL_NIL;
        for my $char (reverse @chars) {
            $ast = make_pair(
                make_char($char),
                $ast,
            );
        }
        return { ast => $ast, pos => $pos };
    }
    elsif ($c eq ";") {
        while ($pos < length($expr) && substr($expr, $pos, 1) ne "\n") {
            ++$pos;
        }
        return _read_helper($expr, $pos);
    }
    else {  # symbol
        my $start = $pos;
        EAT_CHAR:
        {
            do {
                my $cc = substr($expr, $pos, 1);
                # XXX: cheat for now
                last EAT_CHAR if $cc eq ")" or $cc eq "]" or $cc =~ /\s/;
                ++$pos;
            } while ($pos < length($expr));
        }
        my $word = substr($expr, $start, $pos - $start);
        my $ast = index($word, ":") != -1
            ? wrap_in_compose(split /:/, $word)
            : maybe_wrap_in_no($word);
        return { ast => $ast, pos => $pos };
    }
}

sub _rdlist {
    my ($expr, $stopper, $pos) = @_;

    my $skip_whitespace = sub {
        while ($pos < length($expr) && substr($expr, $pos, 1) =~ /\s/) {
            ++$pos;
        }
    };

    ++$pos;
    my @list;
    my $seen_dot = "";
    my $seen_element_after_dot = "";
    while ($pos < length($expr)) {
        $skip_whitespace->();
        my $c = substr($expr, $pos, 1);
        if ($c eq $stopper) {
            ++$pos;
            last;
        }
        elsif ($c eq ".") {
            ++$pos;
            $seen_dot = 1;
        }

        if ($seen_element_after_dot) {
            die "only one element after dot allowed";
        }
        my $r = _read_helper($expr, $pos);
        if ($seen_dot) {
            $seen_element_after_dot = 1;
        }
        push @list, $r->{ast};
        $pos = $r->{pos};
    }
    my $ast = $seen_dot ? pop(@list) : SYMBOL_NIL;
    for my $e (reverse(@list)) {
        $ast = make_pair($e, $ast);
    }
    return { ast => $ast, pos => $pos };
}

sub wrap_in_fn {
    my ($expr) = @_;

    return make_pair(
        make_symbol("fn"),
        make_pair(
            make_pair(
                make_symbol("_"),
                SYMBOL_NIL,
            ),
            make_pair(
                $expr,
                SYMBOL_NIL,
            ),
        ),
    );
}

sub wrap_in_compose {
    my (@parts) = @_;

    my $result = SYMBOL_NIL;
    while (@parts) {
        my $part = pop(@parts);
        $result = make_pair(
            maybe_wrap_in_no($part),
            $result,
        );
    }
    return make_pair(
        make_symbol("compose"),
        $result,
    );
}

sub maybe_wrap_in_no {
    my ($part) = @_;

    return $part eq "~"
        ? make_symbol("no")
        : substr($part, 0, 1) eq "~"
            ? wrap_in_compose("no", substr($part, 1))
            : make_number_or_symbol($part);
}

sub make_number_or_symbol {
    my ($cs) = @_;

    return parsenum($cs) || make_symbol($cs);
}

my $srzero = make_sr("+", 0, 1);
my $srone = make_sr("+", 1, 1);
my $srminusone = make_sr("-", 1, 1);

# (def parsenum (cs base)
#   (if (validi cs base)
#       (buildnum srzero (parsei cs base))
#       (let sign (check (car cs) signc)
#         (let (ds es) (split signc (if sign (cdr cs) cs))
#           (and (validr ds base)
#                (or (no es) (validi es base))
#                (buildnum (parsesr (consif sign ds) base)
#                          (if (no es) srzero (parsei es base))))))))
sub parsenum {
    my ($cs) = @_;

    if (validi($cs)) {
        return buildnum($srzero, parsei($cs));
    }
    else {
        my ($sign, $ds, $es) = $cs =~ /^([+\-]?+)([^+\-]*+)((?:[+\-][^+\-]*+)?+)$/
            or return;
        return validr($ds)
            && ($es eq "" || validi($es))
            && buildnum(parsesr("$sign$ds"), $es eq "" ? $srzero : parsei($es));
    }
}

# (def validi (cs base)
#   (and (signc (car cs))
#        (= (last cs) \i)
#        (let digs (cdr (dock cs))
#          (or (no digs) (validr digs base)))))
sub validi {
    my ($cs) = @_;

    return $cs =~ /^[+-](.*)i$/
        && ($1 eq "" || validr($1));
}

# (def validr (cs base)
#   (or (validd cs base)
#       (let (n d) (split (is \/) cs)
#         (and (validd n base)
#              (validd (cdr d) base)))))
#
# (def validd (cs base)
#   (and (all (cor [digit _ base] (is \.)) cs)
#        (some [digit _ base] cs)
#        (~cdr (keep (is \.) cs))))
sub validr {
    my ($cs) = @_;

    my $validd = sub {
        my ($cs) = @_;

        return $cs =~ /^[\d\.]*+$/ && $cs =~ /\d/;
    };

    if ($validd->($cs)) {
        return 1;
    }
    else {
        my ($n, $d) = $cs =~ /^([^\/]*)\/([^\/]*)$/
            or return;
        return $validd->($n) && $validd->($d);
    }
}

# (def parsei (cs base)
#   (if (cddr cs)
#       (parsesr (dock cs) base)
#       (if (caris cs \+)
#           srone
#           (srinv srone))))
sub parsei {
    my ($cs) = @_;

    return length($cs) > 2
        ? parsesr(substr($cs, 0, -1))
        : substr($cs, 0, 1) eq "+"
            ? $srone
            : $srminusone;
}

sub gcd {
    my ($m, $n) = @_;

    while ($m != 0 && $n != 0) {
        if ($m > $n) {
            $m %= $n;
        }
        else {
            $n %= $m;
        }
    }

    return $m > $n ? $m : $n;
}

# (def parsesr (cs base)
#   (withs (sign  (if (signc (car cs)) (sym (list (car cs))))
#           (n d) (split (is \/) (if sign (cdr cs) cs)))
#     (simplify (cons (or sign '+)
#                     (r/ (parsed n base)
#                         (if d
#                             (let rd (parsed (cdr d) base)
#                               (if (caris rd i0)
#                                   (err 'zero-denominator)
#                                   rd))
#                             (list i1 i1)))))))
sub parsesr {
    my ($cs) = @_;

    my ($sign, $n, $d) = $cs =~ /^([+-]?+)([^\/]*+)((?:\/.*+)?)$/
        or die "Due diligence -- this regex matches everything";
    my $rn = parsed($n);
    my $rd = [1, 1];
    if ($d ne "") {
        $rd = parsed(substr($d, 1));
        if ($rd->[1] == 0) {
            die "zero-denominator";
        }
    }

    # (def simplify ((s n d))
    #   (if (= n i0) (list '+ n i1)
    #       (= n d)  (list s i1 i1)
    #                (let g (apply i* ((of common factor) n d))
    #                  (list s (car:i/ n g) (car:i/ d g)))))
    my $simplify = sub {
        my ($s, $n, $d) = @_;

        if ($n == 0) {
            return "+", $n, 1;
        }
        elsif ($n == $d) {
            return $s, 1, 1;
        }
        else {
            my $g = gcd($n, $d);
            return $s, $n / $g, $d / $g;
        }
    };

    my $r = [$rn->[0] * $rd->[1], $rd->[0] * $rn->[1]];
    return make_sr($simplify->($sign || "+", $r->[0], $r->[1]));
}

# (set buildnum (of litnum simplify))
sub buildnum {
    my ($r, $i) = @_;

    return make_number($r, $i);
}

# (def parsed (cs base)
#   (let (i f) (split (is \.) cs)
#     (if (cdr f)
#         (list (parseint (rev (append i (cdr f))) base)
#               (i^ base
#                   (apply i+ (map (con i1) (cdr f)))))
#         (list (parseint (rev i) base) i1))))
sub parsed {
    my ($cs) = @_;

    my ($i, $f) = $cs =~ /(\d*)((?:\.\d+)?)/
        or die "Due diligence -- this regex will never fail";
    if (length($f) > 0) {
        return [parseint(reverse($i . substr($f, 1))), 10 ** (length($f) - 1)];
    }
    else {
        return [parseint(reverse($i)), 1];
    }
}

# (def parseint (ds base)
#   (if ds
#       (i+ (charint (car ds))
#           (i* base (parseint (cdr ds) base)))
#       i0))
sub parseint {
    my ($ds) = @_;

    my $result = 0;
    for my $d (split //, $ds) {
        $result *= 10;
        $result += ord($d) - ord("0");
    }
    return $result;
}

sub make_number {
    my ($r, $i) = @_;

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

sub make_sr {
    my ($sign, $n, $d) = @_;

    return make_pair(
        make_symbol($sign),
        make_pair(
            make_t_list($n),
            make_pair(
                make_t_list($d),
                SYMBOL_NIL,
            ),
        ),
    );
}

sub make_t_list {
    my ($n) = @_;

    my $list = SYMBOL_NIL;
    for (1..$n) {
        $list = make_pair(SYMBOL_T, $list);
    }
    return $list;
}

our @EXPORT_OK = qw(
    _read
);

1;
