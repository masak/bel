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
        my $ast = make_symbol(substr($expr, $start, $pos - $start));
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

our @EXPORT_OK = qw(
    _read
);

1;
