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
        ++$pos;
        my @list;
        my $seen_dot = "";
        my $seen_element_after_dot = "";
        while ($pos < length($expr)) {
            $skip_whitespace->();
            my $cc = substr($expr, $pos, 1);
            if ($cc eq ")") {
                ++$pos;
                last;
            }
            elsif ($cc eq ".") {
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
    elsif ($c eq "\\") {
        ++$pos;
        my $start = $pos;
        EAT_CHAR:
        {
            do {
                my $cc = substr($expr, $pos, 1);
                # XXX: cheat for now
                last EAT_CHAR if $cc eq ")" or $cc =~ /\s/;
                ++$pos;
            } while ($pos < length($expr));
        }
        my $ast = make_char(substr($expr, $start, $pos - $start));
        return { ast => $ast, pos => $pos };
    }
    else {  # symbol
        my $start = $pos;
        EAT_CHAR:
        {
            do {
                my $cc = substr($expr, $pos, 1);
                # XXX: cheat for now
                last EAT_CHAR if $cc eq ")" or $cc =~ /\s/;
                ++$pos;
            } while ($pos < length($expr));
        }
        my $ast = make_symbol(substr($expr, $start, $pos - $start));
        return { ast => $ast, pos => $pos };
    }
}

our @EXPORT_OK = qw(
    _read
);

1;
