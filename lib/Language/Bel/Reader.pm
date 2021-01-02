package Language::Bel::Reader;

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    make_char
    make_pair
    make_symbol
);
use Language::Bel::Type::Pair::Num qw(
    make_num
);
use Language::Bel::Type::Pair::SignedRat qw(
    make_signed_rat
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

sub read_whole {
    my ($expr) = @_;

    return read_partial($expr, 0)->{ast};
}

my %char_codepoints = (
    bel => 7,
    tab => 9,
    lf => 10,
    cr => 13,
    sp => 32,
);

sub read_partial {
    my ($expr, $pos) = @_;

    $pos ||= 0;

    my $skip_whitespace = sub {
        while ($pos < length($expr) && substr($expr, $pos, 1) =~ /\s/) {
            ++$pos;
        }
    };

    my $breakc = sub {
        my $c;
        return $pos >= length($expr)
            || ($c = substr($expr, $pos, 1)) eq "("
            || $c eq ")"
            || $c eq "["
            || $c eq "]"
            || $c eq " "
            || $c eq "\n";
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
        my $r = read_partial($expr, $pos);
        my $ast = make_pair(SYMBOL_QUOTE, make_pair($r->{ast}, SYMBOL_NIL));
        return { ast => $ast, pos => $r->{pos} };
    }
    elsif ($c eq "`") {
        ++$pos;
        my $r = read_partial($expr, $pos);
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
        my $r = read_partial($expr, $pos);
        my $ast = make_pair($symbol, make_pair($r->{ast}, SYMBOL_NIL));
        return { ast => $ast, pos => $r->{pos} };
    }
    elsif ($c eq "\\") {
        ++$pos;
        my $start = $pos;
        if ($breakc->()) {
            ++$pos;
        }
        else {
            EAT_CHAR:
            {
                while (!$breakc->()) {
                    ++$pos;
                }
            }
        }
        my $name = substr($expr, $start, $pos - $start);
        my $ord = $name eq "¦" || length($name) == 1
            ? ord($name)
            : $char_codepoints{$name};
        die "'unknown-named-char $name\n"
            if !defined($ord);
        my $ast = make_char($ord);
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
                make_char(ord($char)),
                $ast,
            );
        }
        return { ast => $ast, pos => $pos };
    }
    elsif ($c eq ";") {
        while ($pos < length($expr) && substr($expr, $pos, 1) ne "\n") {
            ++$pos;
        }
        return read_partial($expr, $pos);
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
        my $ast = index($word, "|") != -1
            ? parset($word)
            : parseword($word);
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
    my $seen_stopper = "";
    my $seen_element_after_dot = "";
    while ($pos < length($expr)) {
        $skip_whitespace->();
        my $c = substr($expr, $pos, 1);
        if ($c eq $stopper) {
            ++$pos;
            $seen_stopper = 1;
            last;
        }
        elsif ($c eq ".") {
            ++$pos;
            my $cc = substr($expr, $pos, 1);
            if ($cc eq " ") {   # XXX: should be all `breakc`
                $seen_dot = 1;
            }
            else {
                --$pos;
            }
        }

        if ($seen_element_after_dot) {
            die "only one element after dot allowed";
        }
        my $r = read_partial($expr, $pos);
        if ($seen_dot) {
            $seen_element_after_dot = 1;
        }
        push @list, $r->{ast};
        $pos = $r->{pos};
    }
    die "Expected '$stopper', got end of input\n"
        unless $seen_stopper;
    my $ast = $seen_dot ? pop(@list) : SYMBOL_NIL;
    for my $e (reverse(@list)) {
        $ast = make_pair($e, $ast);
    }
    return { ast => $ast, pos => $pos };
}

# (def parset (cs base)
#   (if (cdr (keep (is \|) cs))
#       (err 'multiple-bars)
#       (let vt (tokens cs \|)
#         (if (= (len vt) 2)
#             (cons t (map [parseword _ base] vt))
#             (err 'bad-tspec)))))
sub parset {
    my ($word) = @_;

    if (($word =~ tr/|/|/) > 1) {
        die "multiple-bars";
    }
    my @vt = split(/\|/, $word);
    if (@vt != 2) {
        die "bad-tspec";
    }
    return make_pair(
        SYMBOL_T,
        make_pair(
            parseword($vt[0]),
            make_pair(
                parseword($vt[1]),
                SYMBOL_NIL,
            ),
        ),
    );
}

sub intrac {
    my ($c) = @_;

    return $c eq "." || $c eq "!";
}

sub contains_intrac {
    my ($cs) = @_;

    return index($cs, ".") != -1 || index($cs, "!") != -1;
}

# (def parseword (cs base)
#   (or (parsenum cs base)
#       (if (= cs ".")       (err 'unexpected-dot)
#           (mem \| cs)      (parset cs base)
#           (some intrac cs) (parseslist (runs intrac cs) base)
#                            (parsecom cs base))))
sub parseword {
    my ($cs) = @_;

    if (my $n = parsenum($cs)) {
        return $n;
    }
    elsif ($cs eq ".") {
        die "unexpected-dot";
    }
    elsif (index($cs, "|") != -1) {
        return parset($cs);
    }
    elsif (contains_intrac($cs)) {
        my @runs;
        while ($cs ne "") {
            my $next = substr($cs, 0, 1);
            $cs = substr($cs, 1);
            while (length($cs) && intrac(substr($cs, 0, 1)) == intrac(substr($next, 0, 1))) {
                $next .= substr($cs, 0, 1);
                $cs = substr($cs, 1);
            }
            push @runs, $next;
        }
        return parseslist(\@runs);
    }
    else {
        return parsecom($cs);
    }
}

# (def parseslist (rs base)
#   (if (intrac (car (last rs)))
#       (err 'final-intrasymbol)
#       (map (fn ((cs ds))
#              (if (cdr cs)      (err 'double-intrasymbol)
#                  (caris cs \!) (list 'quote (parsecom ds base))
#                                (parsecom ds base)))
#            (hug (if (intrac (car (car rs)))
#                     (cons "." "upon" rs)
#                     (cons "." rs))))))
sub parseslist {
    my ($runs_ref) = @_;

    my @runs = @$runs_ref;
    my $last_rs = $runs[-1];
    if (intrac(substr($last_rs, 0, 1))) {
        die "final-intrasymbol";
    }
    else {
        my $first_rs = $runs[0];
        if (intrac(substr($first_rs, 0, 1))) {
            unshift @runs, "upon";
        }
        unshift @runs, ".";

        my @result;
        while (@runs >= 2) {
            my $cs = shift @runs;
            my $ds = shift @runs;
            if (length($cs) > 1) {
                die "double-intrasymbol";
            }
            elsif ($cs eq "!") {
                push @result, make_pair(
                    SYMBOL_QUOTE,
                    make_pair(
                        parsecom($ds),
                        SYMBOL_NIL,
                    ),
                );
            }
            else {
                push @result, parsecom($ds);
            }
        }

        my $result = SYMBOL_NIL;
        while (@result) {
            $result = make_pair(
                pop(@result),
                $result,
            );
        }
        return $result;
    }
}

# (def parsecom (cs base)
#   (if (mem \: cs)
#       (cons 'compose (map [parseno _ base] (tokens cs \:)))
#       (parseno cs base)))
sub parsecom {
    my ($cs) = @_;

    if (index($cs, ":") != -1) {
        my @tokens = split /:/, $cs;

        my $tokens = SYMBOL_NIL;
        while (@tokens) {
            $tokens = make_pair(
                parseno(pop(@tokens)),
                $tokens,
            );
        }

        return make_pair(
            make_symbol("compose"),
            $tokens,
        );
    }
    else {
        return parseno($cs);
    }
}

# (def parseno (cs base)
#   (if (caris cs \~)
#       (if (cdr cs)
#           (list 'compose 'no (parseno (cdr cs) base))
#           'no)
#       (or (parsenum cs base) (sym cs))))
sub parseno {
    my ($cs) = @_;

    if (substr($cs, 0, 1) eq "~") {
        if (length($cs) > 1) {
            return make_pair(
                make_symbol("compose"),
                make_pair(
                    make_symbol("no"),
                    make_pair(
                        parseno(substr($cs, 1)),
                        SYMBOL_NIL,
                    ),
                ),
            );
        }
        else {
            return make_symbol("no");
        }
    }
    else {
        return parsenum($cs) || make_symbol($cs);
    }
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

my $srzero = make_signed_rat("+", 0, 1);
my $srone = make_signed_rat("+", 1, 1);
my $srminusone = make_signed_rat("-", 1, 1);

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
        return make_num($srzero, parsei($cs));
    }
    else {
        my ($sign, $ds, $es)
            = $cs =~ /^([+\-]?+)([^+\-]*+)((?:[+\-][^+\-]*+)?+)$/
            or return;
        return validr($ds)
            && ($es eq "" || validi($es))
            && make_num(
                parsesr("$sign$ds"),
                $es eq ""
                    ? $srzero
                    : parsei($es));
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
    return make_signed_rat($simplify->($sign || "+", $r->[0], $r->[1]));
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

our @EXPORT_OK = qw(
    read_whole
    read_partial
);

1;
