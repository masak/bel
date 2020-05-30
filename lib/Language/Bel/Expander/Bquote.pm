package Language::Bel::Expander::Bquote;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_pair
    is_nil
    is_symbol_of_name
    make_pair
    make_symbol
    pair_car
    pair_cdr
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
    SYMBOL_QUOTE
);
use Exporter 'import';

sub _bqexpand {
    my ($ast) = @_;

    if (is_pair($ast)) {
        my $car_ast = pair_car($ast);
        my $cdr_ast = pair_cdr($ast);

        if (is_symbol_of_name($car_ast, "bquote")) {
            return $ast
                unless is_pair($cdr_ast);
            return bquote(pair_car($cdr_ast));
        }
        else {
            return make_pair(
                _bqexpand($car_ast),
                _bqexpand($cdr_ast),
            );
        }
    }

    return $ast;
}

sub bquote {
    my ($e) = @_;

    my ($sub, $change) = bqex($e);
    return $change
        ? $sub
        : make_pair(SYMBOL_QUOTE, make_pair($e, SYMBOL_NIL));
}

sub caris {
    my ($e, $car_sym_name) = @_;

    return is_pair($e)
        && is_symbol_of_name(pair_car($e), $car_sym_name);
}

my $NO_CHANGE = '';
my $CHANGED = 1;

sub bqex {
    my ($e) = @_;

    if (is_nil($e)) {
        return SYMBOL_NIL, $NO_CHANGE;
    }
    elsif (!is_pair($e)) {
        return make_pair(
            SYMBOL_QUOTE,
            make_pair(
                $e,
                SYMBOL_NIL,
            ),
        ), $NO_CHANGE;
    }
    elsif (caris($e, "comma")) {
        return pair_car(pair_cdr(_bqexpand($e))), $CHANGED;
    }
    elsif (caris($e, "comma-at")) {
        return make_pair(
            make_symbol("splice"),
            make_pair(
                pair_car(pair_cdr(_bqexpand($e))),
                SYMBOL_NIL,
            ),
        ), $CHANGED;
    }
    else {
        return bqexpair($e);
    }
}

sub bqexpair {
    my ($e) = @_;

    my ($a, $achange) = bqex(pair_car($e));
    my ($d, $dchange) = bqex(pair_cdr($e));

    if ($achange || $dchange) {
        my $res;
        if (caris($d, "splice")) {
            if (caris($a, "splice")) {
                $res = make_pair(
                    make_symbol("apply"),
                    make_pair(
                        make_symbol("append"),
                        make_pair(
                            pair_car(pair_cdr($a)),
                            make_pair(
                                pair_car(pair_cdr($d)),
                                SYMBOL_NIL,
                            ),
                        ),
                    ),
                );
            }
            else {
                $res = make_pair(
                    make_symbol("apply"),
                    make_pair(
                        make_symbol("cons"),
                        make_pair(
                            $a,
                            make_pair(
                                pair_car(pair_cdr($d)),
                                SYMBOL_NIL,
                            ),
                        ),
                    ),
                );
            }
        }
        else {
            if (caris($a, "splice")) {
                $res = make_pair(
                    make_symbol("append"),
                    make_pair(
                        pair_car(pair_cdr($a)),
                        make_pair($d, SYMBOL_NIL),
                    ),
                );
            }
            else {
                $res = make_pair(
                    make_symbol("cons"),
                    make_pair($a, make_pair($d, SYMBOL_NIL)),
                );
            }
        }
        return $res, $CHANGED;
    }
    else {
        return
            make_pair(SYMBOL_QUOTE, make_pair($e, SYMBOL_NIL)),
            $NO_CHANGE;
    }
}

our @EXPORT_OK = qw(
    _bqexpand
);

1;
