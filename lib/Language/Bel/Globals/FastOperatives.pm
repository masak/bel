package Language::Bel::Globals::FastOperatives;

use 5.006;
use strict;
use warnings;

use Language::Bel::AsyncEval qw(
    make_async_eval
);
use Language::Bel::Core qw(
    is_nil
    make_pair
    SYMBOL_NIL
    SYMBOL_T
);
use Language::Bel::Pair::Num qw(
    maybe_get_int
);

use Exporter 'import';

sub fastoperative__do {
    my ($bel, $denv, @args) = @_;

    my $result = SYMBOL_NIL;

    my $loop;
    $loop = sub {
        my ($index) = @_;

        while ($index < @args) {
            my $arg_ = $args[$index];
            return make_async_eval(
                $arg_,
                $denv,
                sub {
                    my ($r) = @_;
                    $result = $r;
                    return $loop->($index + 1);
                },
            );
        }

        return $result;
    };
    return $loop->(0);
}

sub fastoperative__or {
    my ($bel, $denv, @args) = @_;

    my $loop;
    $loop = sub {
        my ($index) = @_;

        while ($index < @args) {
            my $arg_ = $args[$index];
            return make_async_eval(
                $arg_,
                $denv,
                sub {
                    my ($r) = @_;
                    if (!is_nil($r)) {
                        return $r;
                    }
                    else {
                        return $loop->($index + 1);
                    }
                },
            );
        }

        return SYMBOL_NIL;
    };
    return $loop->(0);
}

sub fastoperative__and {
    my ($bel, $denv, @args) = @_;

    my $result = SYMBOL_T;

    my $loop;
    $loop = sub {
        my ($index) = @_;

        while ($index < @args) {
            my $arg_ = $args[$index];
            return make_async_eval(
                $arg_,
                $denv,
                sub {
                    my ($r) = @_;
                    if (is_nil($r)) {
                        return SYMBOL_NIL;
                    }
                    else {
                        $result = $r;
                        return $loop->($index + 1);
                    }
                },
            );
        }

        return $result;
    };
    return $loop->(0);
}

sub fastoperative__nof {
    my ($bel, $denv, $n_, $expr_) = @_;

    return make_async_eval(
        $n_,
        $denv,
        sub {
            my ($n) = @_;
            my $nn = maybe_get_int($bel, $n);
            die "mistype\n"
                unless defined($nn);
            my $result = make_pair(SYMBOL_NIL, SYMBOL_NIL);
            my $result_tail = $result;
            my $loop;
            $loop = sub {
                while ($nn > 0) {
                    return make_async_eval(
                        $expr_,
                        $denv,
                        sub {
                            my ($expr) = @_;
                            my $new_elem = make_pair($expr, SYMBOL_NIL);
                            $bel->xdr($result_tail, $new_elem);
                            $result_tail = $new_elem;
                            $nn--;
                            return $loop->();
                        },
                    );
                }
                return $bel->cdr($result);
            };
            return $loop->();
        },
    );
}

our @EXPORT_OK = qw(
    fastoperative__do
    fastoperative__or
    fastoperative__and
    fastoperative__nof
);

1;
