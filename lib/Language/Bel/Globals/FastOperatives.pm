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
    make_symbol
    SYMBOL_NIL
    SYMBOL_QUOTE
    SYMBOL_T
);
use Language::Bel::Globals::FastFuncs qw(
    fastfunc__eq
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

sub fastoperative__case {
    my ($bel, $denv, $expr_, @args) = @_;

    my $expr = undef;

    my $loop;
    $loop = sub {
        my ($index) = @_;

        while ($index < @args) {
            if ($index == @args - 1) {
                return make_async_eval($args[$index], $denv);
            }
            else {
                if (defined($expr)) {
                    my $eq = fastfunc__eq($bel, $expr, $args[$index]);
                    if (!is_nil($eq)) {
                        return make_async_eval($args[$index + 1], $denv);
                    }
                    else {
                        return $loop->($index + 2);
                    }
                }
                else {
                    return make_async_eval(
                        $expr_,
                        $denv,
                        sub {
                            $expr = $_[0];
                            my $eq = fastfunc__eq($bel, $expr, $args[$index]);
                            if (!is_nil($eq)) {
                                return make_async_eval(
                                    $args[$index + 1],
                                    $denv,
                                );
                            }
                            else {
                                return $loop->($index + 2);
                            }
                        },
                    );
                }
            }
        }

        return SYMBOL_NIL;
    };
    return $loop->(0);
}

sub fastoperative__iflet {
    my ($bel, $denv, $var_, @args) = @_;

    my $loop;
    $loop = sub {
        my ($index) = @_;

        if ($index >= @args - 1) {
            return make_async_eval($args[$index] || SYMBOL_NIL, $denv);
        }
        else {
            return make_async_eval(
                $args[$index],
                $denv,
                sub {
                    my ($value) = @_;
                    if (!is_nil($value)) {
                        my $extended_denv = make_pair(
                            make_pair($var_, $value),
                            $denv,
                        );
                        return make_async_eval(
                            $args[$index + 1],
                            $extended_denv,
                        );
                    }
                    else {
                        return $loop->($index + 2);
                    }
                },
            );
        }
    };
    return $loop->(0);
}

sub fastoperative__aif {
    my ($bel, $denv, @args) = @_;

    my $loop;
    $loop = sub {
        my ($index) = @_;

        if ($index >= @args - 1) {
            return make_async_eval(
                $args[$index] || SYMBOL_NIL,
                $denv,
            );
        }
        else {
            return make_async_eval(
                $args[$index],
                $denv,
                sub {
                    my ($value) = @_;
                    if (!is_nil($value)) {
                        my $extended_denv = make_pair(
                            make_pair(make_symbol("it"), $value),
                            $denv,
                        );
                        return make_async_eval(
                            $args[$index + 1],
                            $extended_denv,
                        );
                    }
                    else {
                        return $loop->($index + 2);
                    }
                },
            );
        }
    };
    return $loop->(0);
}

sub fastoperative__pcase {
    my ($bel, $denv, $expr_, @args) = @_;

    my $expr = undef;

    my $loop;
    $loop = sub {
        my ($index) = @_;

        while ($index < @args) {
            if ($index == @args - 1) {
                return make_async_eval(
                    $args[$index],
                    $denv,
                );
            }
            else {
                if (defined($expr)) {
                    return make_async_eval(
                        make_pair(
                            $args[$index],
                            make_pair(
                                make_pair(
                                    SYMBOL_QUOTE,
                                    make_pair(
                                        $expr,
                                        SYMBOL_NIL,
                                    ),
                                ),
                                SYMBOL_NIL,
                            ),
                        ),
                        $denv,
                        sub {
                            my ($eq) = @_;
                            return !is_nil($eq)
                                ? make_async_eval($args[$index + 1], $denv)
                                : $loop->($index + 2);
                        },
                    );
                }
                else {
                    return make_async_eval(
                        $expr_,
                        $denv,
                        sub {
                            $expr = $_[0];

                            return make_async_eval(
                                make_pair(
                                    $args[$index],
                                    make_pair(
                                        make_pair(
                                            SYMBOL_QUOTE,
                                            make_pair(
                                                $expr,
                                                SYMBOL_NIL,
                                            ),
                                        ),
                                        SYMBOL_NIL,
                                    ),
                                ),
                                $denv,
                                sub {
                                    my ($eq) = @_;
                                    return !is_nil($eq)
                                        ? make_async_eval(
                                            $args[$index + 1],
                                            $denv)
                                        : $loop->($index + 2);
                                },
                            );
                        },
                    );
                }
            }
        }

        return SYMBOL_NIL;
    };
    return $loop->(0);
}

my $UNSET = {};

sub fastoperative__do1 {
    my ($bel, $denv, @args) = @_;

    my $result = $UNSET;

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
                    if ($result == $UNSET) {
                        $result = $r;
                    }
                    return $loop->($index + 1);
                },
            );
        }

        return $result == $UNSET
            ? SYMBOL_NIL
            : $result;
    };
    return $loop->(0);
}

sub fastoperative__whenlet {
    my ($bel, $denv, $var_, $expr_, @body) = @_;

    return make_async_eval(
        $expr_,
        $denv,
        sub {
            my ($value) = @_;

            return SYMBOL_NIL
                if is_nil($value);

            my $extended_denv = make_pair(
                make_pair($var_, $value),
                $denv,
            );

            my $result = SYMBOL_NIL;

            my $loop;
            $loop = sub {
                my ($index) = @_;

                while ($index < @body) {
                    my $statement_ = $body[$index];
                    return make_async_eval(
                        $statement_,
                        $extended_denv,
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
        },
    );
}

sub fastoperative__awhen {
    my ($bel, $denv, $expr_, @body) = @_;

    return make_async_eval(
        $expr_,
        $denv,
        sub {
            my ($value) = @_;

            return SYMBOL_NIL
                if is_nil($value);

            my $extended_denv = make_pair(
                make_pair(make_symbol("it"), $value),
                $denv,
            );

            my $result = SYMBOL_NIL;

            my $loop;
            $loop = sub {
                my ($index) = @_;

                while ($index < @body) {
                    my $statement_ = $body[$index];
                    return make_async_eval(
                        $statement_,
                        $extended_denv,
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
        },
    );
}

sub fastoperative__whilet {
    my ($bel, $denv, $var_, $expr_, @body) = @_;

    my $while_loop;
    $while_loop = sub {
        return make_async_eval(
            $expr_,
            $denv,
            sub {
                my ($value) = @_;

                return SYMBOL_NIL
                    if is_nil($value);

                my $extended_denv = make_pair(
                    make_pair($var_, $value),
                    $denv,
                );

                my $statement_loop;
                $statement_loop = sub {
                    my ($index) = @_;

                    while ($index < @body) {
                        my $statement_ = $body[$index];
                        return make_async_eval(
                            $statement_,
                            $extended_denv,
                            sub {
                                return $statement_loop->($index + 1);
                            },
                        );
                    }

                    return $while_loop->();
                };
                return $statement_loop->(0);
            },
        );
    };
    return $while_loop->();

}

sub fastoperative__loop {
    my ($bel, $denv, $var_, $init_, $update_, $test_, @body) = @_;

    return make_async_eval(
        $init_,
        $denv,
        sub {
            my ($init) = @_;

            my $loop;
            $loop = sub {
                my ($value) = @_;

                my $extended_denv = make_pair(
                    make_pair($var_, $value),
                    $denv,
                );

                return make_async_eval(
                    $test_,
                    $extended_denv,
                    sub {
                        my ($condition) = @_;

                        return SYMBOL_NIL
                            if is_nil($condition);

                        my $statement_loop;
                        $statement_loop = sub {
                            my ($index) = @_;

                            while ($index < @body) {
                                my $statement_ = $body[$index];
                                return make_async_eval(
                                    $statement_,
                                    $extended_denv,
                                    sub {
                                        return $statement_loop->($index + 1);
                                    },
                                );
                            }

                            return make_async_eval(
                                $update_,
                                $extended_denv,
                                $loop,
                            );
                        };
                        return $statement_loop->(0);
                    },
                );
            };
            return $loop->($init);
        },
    );
}

sub fastoperative__while {
    my ($bel, $denv, $expr_, @body) = @_;

    return make_async_eval(
        $expr_,
        $denv,
        sub {
            my ($init) = @_;

            my $loop;
            $loop = sub {
                my ($value) = @_;

                return SYMBOL_NIL
                    if is_nil($value);

                my $statement_loop;
                $statement_loop = sub {
                    my ($index) = @_;

                    while ($index < @body) {
                        my $statement_ = $body[$index];
                        return make_async_eval(
                            $statement_,
                            $denv,
                            sub {
                                return $statement_loop->($index + 1);
                            },
                        );
                    }

                    return make_async_eval(
                        $expr_,
                        $denv,
                        $loop,
                    );
                };
                return $statement_loop->(0);
            };

            return $loop->($init);
        },
    );
}

sub fastoperative__til {
    my ($bel, $denv, $var_, $expr_, $test_, @body) = @_;

    return make_async_eval(
        $expr_,
        $denv,
        sub {
            my ($init) = @_;

            my $loop;
            $loop = sub {
                my ($value) = @_;

                my $extended_denv = make_pair(
                    make_pair($var_, $value),
                    $denv,
                );

                return make_async_eval(
                    $test_,
                    $extended_denv,
                    sub {
                        my ($condition) = @_;

                        return SYMBOL_NIL
                            unless is_nil($condition);

                        my $statement_loop;
                        $statement_loop = sub {
                            my ($index) = @_;

                            while ($index < @body) {
                                my $statement_ = $body[$index];
                                return make_async_eval(
                                    $statement_,
                                    $extended_denv,
                                    sub {
                                        return $statement_loop->($index + 1);
                                    },
                                );
                            }

                            return make_async_eval(
                                $expr_,
                                $extended_denv,
                                $loop,
                            );
                        };
                        return $statement_loop->(0);
                    },
                );
            };
            return $loop->($init);
        },
    );
}

sub fastoperative__repeat {
    my ($bel, $denv, $n_, @body) = @_;

    return make_async_eval(
        $n_,
        $denv,
        sub {
            my ($n) = @_;
            my $nn = maybe_get_int($bel, $n);
            die "mistype\n"
                unless defined($nn);
            my $loop;
            $loop = sub {
                my ($iteration) = @_;

                while ($iteration < $nn) {
                    my $statement_loop;
                    $statement_loop = sub {
                        my ($index) = @_;

                        while ($index < @body) {
                            my $statement_ = $body[$index];
                            return make_async_eval(
                                $statement_,
                                $denv,
                                sub {
                                    return $statement_loop->($index + 1);
                                },
                            );
                        }

                        return $loop->($iteration + 1);
                    };

                    return $statement_loop->(0);
                }

                return SYMBOL_NIL;
            };
            return $loop->(0);
        },
    );
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
    fastoperative__case
    fastoperative__iflet
    fastoperative__aif
    fastoperative__pcase
    fastoperative__do1
    fastoperative__whenlet
    fastoperative__awhen
    fastoperative__whilet
    fastoperative__loop
    fastoperative__while
    fastoperative__til
    fastoperative__repeat
    fastoperative__nof
);

1;
