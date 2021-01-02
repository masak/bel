package Language::Bel;

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    are_identical
    atoms_are_identical
    is_char
    is_nil
    is_pair
    is_string
    is_symbol
    is_symbol_of_name
    make_pair
    make_symbol
    pair_car
    pair_cdr
    pairs_are_identical
    symbol_name
    symbols_are_identical
);
use Language::Bel::Type::Pair::FastFunc qw(
    is_fastfunc
);
use Language::Bel::Type::Pair::FutFunc qw(
    make_futfunc
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_LOCK
    SYMBOL_NIL
);
use Language::Bel::Primitives;
use Language::Bel::Reader qw(
    read_whole
);
use Language::Bel::Globals;
use Language::Bel::Printer qw(
    _print
);

=head1 NAME

Language::Bel - An interpreter for Paul Graham's language Bel

=head1 VERSION

Version 0.50

=cut

our $VERSION = '0.50';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Language::Bel;

    my $foo = Language::Bel->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my ($class, $options_ref) = @_;
    my $self = {
        ref($options_ref) eq "HASH" ? %$options_ref : (),
    };

    $self = bless($self, $class);
    if (!defined($self->{output})) {
        $self->{output} = sub {
            my ($string) = @_;
            print($string);
        };
    }
    if (!defined($self->{primitives})) {
        $self->{primitives} = Language::Bel::Primitives->new({
            output => $self->{output},
            err => sub {
                my ($message_str) = @_;

                my $message_symbol = make_symbol($message_str);
                my $symbol_err = make_symbol("err");
                my $err_kv = $self->lookup($symbol_err, SYMBOL_NIL);
                die "Fatal: could not find 'err'"
                    unless $err_kv && is_pair($err_kv);
                my $err = $self->cdr($err_kv);
                $self->call($err, $message_symbol);
            },
        });
    }
    if (!defined($self->{globals})) {
        $self->{globals} = Language::Bel::Globals->new(
            primitives => $self->{primitives},
        );
    }

    return $self;
}

sub car {
    my ($self, $pair) = @_;

    $self->{primitives}->prim_car($pair);
}

sub cdr {
    my ($self, $pair) = @_;

    $self->{primitives}->prim_cdr($pair);
}

sub xdr {
    my ($self, $pair, $d) = @_;

    $self->{primitives}->prim_xdr($pair, $d);
}

sub call {
    my ($self, $fn, @args) = @_;

    if (is_fastfunc($fn)) {
        return $fn->apply($self, @args);
    }
    else {
        my $args = SYMBOL_NIL;
        for my $arg (reverse(@args)) {
            $args = make_pair($arg, $args);
        }

        my $s_level = scalar(@{$self->{s}});
        $self->applyf($fn, $args, SYMBOL_NIL);

        while (scalar(@{$self->{s}}) > $s_level) {
            $self->ev();
        }
        my $retval = pop(@{$self->{r}});
        return $retval;
    }
}

=head2 read_eval_print

Evaluates an expression, passed in as a string of Bel code.
Prints the result.

=cut

sub read_eval_print {
    my ($self, $expr) = @_;

    my $ast = read_whole($expr);
    my $eval_result = $self->eval($ast);
    my $result_string = _print($eval_result);

    $self->output($result_string);
    $self->output("\n");

    return;
}

sub output {
    my ($self, $string) = @_;

    my $output = $self->{output};
    if (ref($output) eq "CODE") {
        $output->($string);
    }

    return;
}

# (def bel (e (o g globe))
#   (ev (list (list e nil))
#       nil
#       (list nil g)))
sub eval {
    my ($self, $ast) = @_;

    $self->{s} = [[$ast, SYMBOL_NIL]];
    $self->{r} = [];
    $self->{p} = [];

    while (@{$self->{s}} || @{$self->{p}}) {
        $self->ev();

        # (def mev (s r (p g))  
        #   (if (no s) 
        #       (if p  
        #           (sched p g)
        #           (car r))
        #       (sched (if (cdr (binding 'lock s))
        #                  (cons (list s r) p)
        #                  (snoc p (list s r)))
        #              g)))
        my $b = $self->binding(SYMBOL_LOCK);
        if (!$b || is_nil($self->cdr($b))) {
            if (@{$self->{s}}) {
                my $s = $self->{s};
                my $r = $self->{r};
                push @{$self->{p}}, [$s, $r];
            }

            if (@{$self->{p}}) {
                my $sr = shift @{$self->{p}};
                $self->{s} = $sr->[0];
                $self->{r} = $sr->[1];
            }
        }
    }
    return $self->{r}[-1];
}

# (mac fu args
#   `(list (list smark 'fut (fn ,@args)) nil))
sub fut {
    my ($self, $source, $sub) = @_;
    my $smark = $self->cdr($self->{globals}->get_kv("smark"));

    return [
        make_pair(
            $smark,
            make_pair(
                make_symbol("fut"),
                make_pair(
                    make_futfunc(
                        $source,
                        $sub,
                    ),
                    SYMBOL_NIL,
                ),
            ),
        ),
        SYMBOL_NIL,
    ];
}

my %forms = (
    # (form quote ((e) a s r m)
    #   (mev s (cons e r) m))
    quote => sub {
        my ($bel, $es, $a) = @_;

        # XXX: skipping $es sanity check for now
        my $e = pair_car($es);
        push @{$bel->{r}}, $e;
    },

    # (form if (es a s r m)
    #   (if (no es)
    #       (mev s (cons nil r) m)
    #       (mev (cons (list (car es) a)
    #                  (if (cdr es)
    #                      (cons (fu (s r m)
    #                              (if2 (cdr es) a s r m))
    #                            s)
    #                      s))
    #            r
    #            m)))
    if => sub {
        my ($bel, $es, $a) = @_;

        if (is_nil($es)) {
            push @{$bel->{r}}, SYMBOL_NIL;
        }
        else {
            my $cdr_es = $bel->cdr($es);
            if (!is_nil($cdr_es)) {
                my $fu = $bel->fut(
                    <<'FUT',
                    (fn (s r m)
                      (if2 (cdr es) a s r m))
FUT
                    sub {
                        if2($bel, $bel->cdr($es), $a);
                    },
                );
                push @{$bel->{s}}, $fu;
            }
            push @{$bel->{s}}, [$bel->car($es), $a];
        }
    },

    # (form where ((e (o new)) a s r m)
    #   (mev (cons (list e a)
    #              (list (list smark 'loc new) nil)
    #              s)
    #        r
    #        m))
    where => sub {
        my ($bel, $e_new, $a) = @_;
        my $e = $bel->car($e_new);
        my $smark = $bel->cdr($bel->{globals}->get_kv("smark"));
        my $new = $bel->car($bel->cdr($e_new));

        push @{$bel->{s}}, [
            make_pair(
                $smark,
                make_pair(
                    make_symbol("loc"),
                    make_pair(
                        $new,
                        SYMBOL_NIL,
                    ),
                ),
            ),
            SYMBOL_NIL,
        ];
        push @{$bel->{s}}, [$e, $a];
    },

    # (form dyn ((v e1 e2) a s r m)
    #   (if (variable v)
    #       (mev (cons (list e1 a)
    #                  (fu (s r m) (dyn2 v e2 a s r m))
    #                  s)
    #            r
    #            m)
    #       (sigerr 'cannot-bind s r m)))
    dyn => sub {
        my ($bel, $es, $a) = @_;

        # XXX: skipping $es sanity check for now
        my $v = $bel->car($es);
        my $e1 = $bel->car($bel->cdr($es));
        my $e2 = $bel->car($bel->cdr($bel->cdr($es)));

        if ($bel->variable($v)) {
            my $fu = $bel->fut(
                <<'FUT',
                    (fn (s r m) (dyn2 v e2 a s r m))
FUT
                sub {
                    dyn2($bel, $v, $e2, $a);
                },
            );
            push @{$bel->{s}}, $fu, [$e1, $a];
        }
        else {
            die "'cannot-bind\n";
        }
    },

    # (form after ((e1 e2) a s r m)
    #   (mev (cons (list e1 a)
    #              (list (list smark 'prot e2) a)
    #              s)
    #        r
    #        m))
    after => sub {
        my ($bel, $es, $a) = @_;

        # XXX: skipping $es sanity check for now
        my $e1 = $bel->car($es);
        my $e2 = $bel->car($bel->cdr($es));
        my $smark = $bel->cdr($bel->{globals}->get_kv("smark"));

        my $prot = [
            make_pair(
                $smark,
                make_pair(
                    make_symbol("prot"),
                    make_pair(
                        $e2,
                        SYMBOL_NIL,
                    ),
                ),
            ),
            $a,
        ];
        push @{$bel->{s}}, $prot, [$e1, $a];
    },

    # (form thread ((e) a s r (p g))
    #   (mev s
    #        (cons nil r)
    #        (list (cons (list (list (list e a))
    #                          nil)
    #                    p)
    #              g)))
    thread => sub {
        my ($bel, $es, $a) = @_;

        # XXX: skipping $es sanity check for now
        my $e = $bel->car($es);

        push @{$bel->{r}}, SYMBOL_NIL;

        my $new_thread = [[[$e, $a]], []];
        push @{$bel->{p}}, $new_thread;
    },

    # (form ccc ((f) a s r m)
    #   (mev (cons (list (list f (list 'lit 'cont s r))
    #                    a)
    #              s)
    #        r
    #        m))
    ccc => sub {
        my ($bel, $es, $a) = @_;

        # XXX: skipping $es sanity checks for now
        my $f = $bel->car($es);

        my $s = SYMBOL_NIL;
        for my $entry (@{$bel->{s}}) {
            die "s stack invariant broken: ", ref($entry), "\n"
                unless ref($entry) eq "ARRAY";

            my $e = $entry->[0];
            my $a = $entry->[1];

            $s = make_pair(
                make_pair(
                    $e,
                    make_pair(
                        $a,
                        SYMBOL_NIL,
                    ),
                ),
                $s,
            );
        }

        my $r = SYMBOL_NIL;
        for my $value (@{$bel->{r}}) {
            $r = make_pair(
                $value,
                $r,
            );
        }

        my $continuation = make_pair(
            make_symbol("lit"),
            make_pair(
                make_symbol("cont"),
                make_pair(
                    $s,
                    make_pair(
                        $r,
                        SYMBOL_NIL,
                    ),
                ),
            ),
        );
        my $call_f_with_cont = make_pair(
            $f,
            make_pair(
                $continuation,
                SYMBOL_NIL,
            ),
        );
        push @{$bel->{s}}, [$call_f_with_cont, $a];
    },
);

# (def if2 (es a s r m)
#   (mev (cons (list (if (car r)
#                        (car es)
#                        (cons 'if (cdr es)))
#                    a)
#              s)
#        (cdr r)
#        m))
sub if2 {
    my ($bel, $es, $a) = @_;

    my $car_r = pop(@{$bel->{r}});
    my $e = !is_nil($car_r)
        ? $bel->car($es)
        : make_pair(make_symbol("if"), $bel->cdr($es));
    push @{$bel->{s}}, [$e, $a];
}

# (def dyn2 (v e2 a s r m)
#   (mev (cons (list e2 a)
#              (list (list smark 'bind (cons v (car r)))
#                    nil)
#              s)
#        (cdr r)
#        m))
sub dyn2 {
    my ($bel, $v, $e2, $a) = @_;

    my $smark = $bel->cdr($bel->{globals}->get_kv("smark"));
    my $car_r = pop(@{$bel->{r}});
    push @{$bel->{s}},
        [make_pair(
            $smark,
            make_pair(
                make_symbol("bind"),
                make_pair(
                    make_pair($v, $car_r),
                    SYMBOL_NIL,
                ),
            ),
        ), SYMBOL_NIL],
        [$e2, $a];
}

# (def ev (((e a) . s) r m)
#   (aif (literal e)            (mev s (cons e r) m)
#        (variable e)           (vref e a s r m)
#        (no (proper e))        (sigerr 'malformed s r m)
#        (get (car e) forms id) ((cdr it) (cdr e) a s r m)
#                               (evcall e a s r m)))
sub ev {
    my ($self) = @_;

    my $entry = pop @{$self->{s}};
    die "s stack invariant broken: ", ref($entry), "\n"
        unless ref($entry) eq "ARRAY";

    my $e = $entry->[0];
    my $a = $entry->[1];

    my $is_form = sub {
        my ($e) = @_;

        my $car = pair_car($e);
        return unless is_symbol($car);

        my $name = symbol_name($car);
        return $forms{$name};
    };

    if (literal($e)) {
        push @{$self->{r}}, $e;
    }
    elsif ($self->variable($e)) {
        $self->vref($e, $a);
    }
    elsif (is_pair($e)
        && $self->{globals}->is_global_of_name($self->car($e), "smark")) {
        $self->evmark($self->cdr($e), $a);
    }
    # (def evmark (e a s r m)
    #   (case (car e)
    #     fut  ((cadr e) s r m)
    #     bind (mev s r m)
    #     loc  (sigerr 'unfindable s r m)
    #     prot (mev (cons (list (cadr e) a)
    #                     (fu (s r m) (mev s (cdr r) m))
    #                     s)
    #               r
    #               m)
    #          (sigerr 'unknown-mark s r m)))
    elsif (!proper($e)) {
        die "'malformed\n";
    }
    elsif (my $form = $is_form->($e)) {
        $form->($self, pair_cdr($e), $a);
    }
    else {
        $self->evcall($e, $a);
    }
}

# (def literal (e)
#   (or (in e t nil o apply)
#       (in (type e) 'char 'stream)
#       (caris e 'lit)
#       (string e)))
sub literal {
    my ($e) = @_;

    my $is_self_evaluating = sub {
        return is_symbol_of_name($e, "t")
            || is_symbol_of_name($e, "nil")
            || is_symbol_of_name($e, "o")
            || is_symbol_of_name($e, "apply");
    };

    my $is_lit = sub {
        return unless is_pair($e);

        my $car = pair_car($e);
        return is_symbol_of_name($car, "lit");
    };

    return (
        $is_self_evaluating->() ||
        is_char($e) ||
        # XXX: skipping is_stream case for now
        $is_lit->() ||
        is_string($e)
    );
}

# (def variable (e)
#   (if (atom e)
#       (no (literal e))
#       (id (car e) vmark)))
sub variable {
    my ($self, $e) = @_;

    return is_pair($e)
        ? $self->{globals}->is_global_of_name(pair_car($e), "vmark")
        : !literal($e);
}

# (def proper (x)
#   (or (no x)
#       (and (pair x) (proper (cdr x)))))
sub proper {
    my ($e) = @_;

    while (!is_nil($e)) {
        return
            if (!is_pair($e));
        $e = pair_cdr($e);
    }
    return 1;
}

# (def vref (v a s r m)
#   (let g (cadr m)
#     (if (inwhere s)
#         (aif (or (lookup v a s g)
#                  (and (car (inwhere s))
#                       (let cell (cons v nil)
#                         (xdr g (cons cell (cdr g)))
#                         cell)))
#              (mev (cdr s) (cons (list it 'd) r) m)
#              (sigerr 'unbound s r m))
#         (aif (lookup v a s g)
#              (mev s (cons (cdr it) r) m)
#              (sigerr (list 'unboundb v) s r m)))))
sub vref {
    my ($self, $v, $a) = @_;

    my $it;
    if ($it = $self->inwhere()) {
        my $car_inwhere = $self->car($it);
        if (is_pair($it = $self->lookup($v, $a))
            || !is_nil($car_inwhere) && ($it = $self->{globals}->install($v))) {
            pop @{$self->{s}};  # get rid of the (smark 'loc)
            push @{$self->{r}}, make_pair(
                $it,
                make_pair(
                    make_symbol("d"),
                    SYMBOL_NIL,
                ),
            );
        }
        else {
            die "'unbound\n";
        }
    }
    elsif (is_pair($it = $self->lookup($v, $a))) {
        push @{$self->{r}}, pair_cdr($it);
    }
    else {
        my $name = is_symbol($v)
            ? symbol_name($v)
            : "<not a symbol>";
        die "('unboundb $name)\n";
    }
}

# (def inwhere (s)
#   (let e (car (car s))
#     (and (begins e (list smark 'loc))
#          (cddr e))))
sub inwhere {
    my ($self) = @_;

    my $e;
    return @{$self->{s}}
        && is_pair($e = $self->{s}[-1][0])
        && $self->{globals}->is_global_of_name($self->car($e), "smark")
        && is_symbol_of_name($self->car($self->cdr($e)), "loc")
        && $self->cdr($self->cdr($e));
}

# (def get (k kvs (o f =))
#   (find [f (car _) k] kvs))
sub get {
    my ($k, $kvs) = @_;

    my $equal = sub {
        my ($first, $second) = @_;

        return 1
            if is_symbol($first)
            && is_symbol($second)
            && symbols_are_identical($first, $second);
        return is_pair($first)
            && is_pair(pair_car($first))
            && is_nil(pair_cdr($first))
            && is_pair($second)
            && pairs_are_identical($first, $second);
    };

    while (!is_nil($kvs)) {
        my $kv = pair_car($kvs);
        my $key = pair_car($kv);

        if ($equal->($key, $k)) {
            return $kv;
        }
        $kvs = pair_cdr($kvs);
    }
    return;
}

# (def lookup (e a s g)
#   (or (binding e s)
#       (get e a id)
#       (get e g id)
#       (case e
#         scope (cons e a)
#         globe (cons e g))))
sub lookup {
    my ($self, $e, $a) = @_;

    return $self->binding($e)
        || get($e, $a)
        || (is_symbol($e) && $self->{globals}->get_kv(symbol_name($e)))
        || (is_symbol_of_name($e, "scope") && make_pair($e, $a))
        || (is_symbol_of_name($e, "globe") && make_pair($e, $self->{globals}->list()))
        || SYMBOL_NIL;
}

# (def binding (v s)
#   (get v
#        (map caddr (keep [begins _ (list smark 'bind) id]
#                         (map car s)))
#        id))
sub binding {
    my ($self, $v) = @_;

    for my $entry (reverse @{$self->{s}}) {
        next if ref($entry) eq "CODE";
        my $e = $entry->[0];

        next unless is_pair($e)
            && $self->{globals}->is_global_of_name($self->car($e), "smark")
            && is_symbol_of_name($self->car($self->cdr($e)), "bind");
        my $smark_value = $self->car($self->cdr($self->cdr($e)));
        next unless are_identical(pair_car($smark_value), $v);
        return $smark_value;
    }

    return;
}

# (def evmark (e a s r m)
#   (case (car e)
#     fut  ((cadr e) s r m)
#     bind (mev s r m)
#     loc  (sigerr 'unfindable s r m)
#     prot (mev (cons (list (cadr e) a)
#                     (fu (s r m) (mev s (cdr r) m))
#                     s)
#               r
#               m)
#          (sigerr 'unknown-mark s r m)))
sub evmark {
    my ($self, $e, $a) = @_;

    my $car_e = $self->car($e);
    if (is_symbol_of_name($car_e, "fut")) {
        $self->car($self->cdr($e))->apply();
    }
    elsif (is_symbol_of_name($car_e, "bind")) {
        # do nothing; already popped it off the stack
    }
    elsif (is_symbol_of_name($car_e, "loc")) {
        die "'unfindable\n";
    }
    elsif (is_symbol_of_name($car_e, "prot")) {
        my $fu = $self->fut(
            <<'FUT',
                (fn (s r m) (mev s (cdr r) m))
FUT
            sub {
                pop @{$self->{r}};
            },
        );
        push @{$self->{s}}, $fu, [$self->car($self->cdr($e)), $a];
    }
    else {
        die "Unknown smark";
    }
}

# (def evcall (e a s r m)
#   (mev (cons (list (car e) a)
#              (fu (s r m)
#                (evcall2 (cdr e) a s r m))
#              s)
#        r
#        m))
sub evcall {
    my ($self, $e, $a) = @_;

    my $fu1 = $self->fut(
        <<'FUT',
            (fn (s r m) (evcall2 (cdr e) a s r m))
FUT
        # (def evcall2 (es a s (op . r) m)
        #   (if ((isa 'mac) op)
        #       (applym op es a s r m)
        #       (mev (append (map [list _ a] es)
        #                    (cons (fu (s r m)
        #                            (let (args r2) (snap es r)
        #                              (applyf op (rev args) a s r2 m)))
        #                          s))
        #            r
        #            m)))
        sub {
            my $op = pop @{$self->{r}};

            my $isa_mac = sub {
                my ($v) = @_;

                return is_pair($v)
                    && is_symbol_of_name($self->car($v), "lit")
                    && is_pair($self->cdr($v))
                    && is_symbol_of_name($self->car($self->cdr($v)), "mac");
            };

            my $es = pair_cdr($e);
            if ($isa_mac->($op)) {
                $self->applym($op, $es, $a);
            }
            else {
                my $fu2 = $self->fut(
                    <<'FUT',
                        (fn (s r m)
                          (let (args r2) (snap es r)
                            (applyf op (rev args) a s r2 m)))
FUT
                    sub {
                        my $args = SYMBOL_NIL;
                        my @args;
                        my $es = pair_cdr($e);
                        while (!is_nil($es)) {
                            my $arg = pop(@{$self->{r}});
                            $args = make_pair($arg, $args);
                            unshift @args, $arg;
                            $es = pair_cdr($es);
                        }
                        if (is_fastfunc($op)) {
                            my $e;
                            if ($self->inwhere() && $op->handles_where()) {
                                $e = $op->where_apply($self, @args);
                                if (!is_nil($e)) {
                                    pop @{$self->{s}};  # get rid of the (smark 'loc)
                                }
                            }
                            else {
                                $e = $op->apply($self, @args);
                            }
                            push @{$self->{r}}, $e;
                        }
                        else {
                            $self->applyf($op, $args, $a);
                        }
                    },
                );

                my @unevaluated_arguments;
                while (!is_nil($es)) {
                    push @unevaluated_arguments, [pair_car($es), $a];
                    $es = pair_cdr($es);
                }
                # We want to evaluate the arguments in the order `a b c`,
                # so we need to put them on expression stack in the order
                # `c b a`. That's why we use `@unevaluated_arguments` as
                # an intermediary, to reverse the order.
                push @{$self->{s}}, $fu2, reverse(@unevaluated_arguments);
            }
        },
    );
    push @{$self->{s}}, $fu1, [pair_car($e), $a];
}

# (def applym (mac args a s r m)
#   (applyf (caddr mac)
#           args
#           a
#           (cons (fu (s r m)
#                   (mev (cons (list (car r) a) s)
#                        (cdr r)
#                        m))
#                 s)
#           r
#           m))
sub applym {
    my ($self, $mac, $args, $a) = @_;

    my $mac_clo = $self->car($self->cdr($self->cdr($mac)));
    my $fu = $self->fut(
        <<'FUT',
            (fn (s r m)
              (mev (cons (list (car r) a) s)
                   (cdr r)
                   m))
FUT
        sub {
            my $macro_expansion = pop @{$self->{r}};
            push @{$self->{s}}, [$macro_expansion, $a];
        },
    );
    push @{$self->{s}}, $fu;
    $self->applyf($mac_clo, $args, $a);
}

# (def applyf (f args a s r m)
#   (if (= f apply)    (applyf (car args) (reduce join (cdr args)) a s r m)
#       (caris f 'lit) (if (proper f)
#                          (applylit f args a s r m)
#                          (sigerr 'bad-lit s r m))
#                      (sigerr 'cannot-apply s r m)))
sub applyf {
    my ($self, $f, $args, $a) = @_;

    if (is_symbol_of_name($f, "apply")) {
        my $apply_op = $self->car($args);
        my $it_arg = $self->cdr($args);
        my @stack;
        while (!is_nil($it_arg)) {
            push @stack, $self->car($it_arg);
            $it_arg = $self->cdr($it_arg);
        }
        my $apply_args = @stack ? pop(@stack) : SYMBOL_NIL;
        while (@stack) {
            $apply_args = make_pair(
                pop(@stack),
                $apply_args,
            );
        }

        $self->applyf($apply_op, $apply_args, $a);
    }
    else {
        if (!is_pair($f) || !is_symbol_of_name(pair_car($f), "lit")) {
            die "'cannot-apply\n";
        }
        # XXX: skipping `proper` check for now
        $self->applylit($f, $args, $a);
    }
}

# (def applylit (f args a s r m)
#   (aif (and (inwhere s) (find [(car _) f] locfns))
#        ((cadr it) f args a s r m)
#        (let (tag . rest) (cdr f)
#          (case tag
#            prim (applyprim (car rest) args s r m)
#            clo  (let ((o env) (o parms) (o body) . extra) rest
#                   (if (and (okenv env) (okparms parms))
#                       (applyclo parms args env body s r m)
#                       (sigerr 'bad-clo s r m)))
#            mac  (applym f (map [list 'quote _] args) a s r m)
#            cont (let ((o s2) (o r2) . extra) rest
#                   (if (and (okstack s2) (proper r2))
#                       (applycont s2 r2 args s r m)
#                       (sigerr 'bad-cont s r m)))
#                 (aif (get tag virfns)
#                      (let e ((cdr it) f (map [list 'quote _] args))
#                        (mev (cons (list e a) s) r m))
#                      (sigerr 'unapplyable s r m))))))
sub applylit {
    my ($self, $f, $args, $a) = @_;

    my $it;
    if ($self->inwhere() && ($it = $self->findlocfn($f, $args))) {
        pop @{$self->{s}};  # get rid of the (smark 'loc)
        push @{$self->{r}}, $it;
    }
    else {
        my $tag = pair_car(pair_cdr($f));
        my $tag_name = symbol_name($tag);
        my $rest = pair_cdr(pair_cdr($f));
        if ($tag_name eq "prim") {
            $self->applyprim(pair_car($rest), $args);
        }
        elsif ($tag_name eq "clo") {
            my $env = $self->car($rest);
            my $parms = $self->car($self->cdr($rest));
            my $body = $self->car($self->cdr($self->cdr($rest)));

            # XXX: skipping `okenv` and `okparms` checks for now
            $self->applyclo($parms, $args, $env, $body);
        }
        elsif ($tag_name eq "mac") {
            my @stack;
            while (!is_nil($args)) {
                push @stack, $self->car($args);
                $args = $self->cdr($args);
            }
            my $quoted_args = SYMBOL_NIL;
            while (@stack) {
                $quoted_args = make_pair(
                    pop(@stack),
                    $quoted_args,
                );
            }

            $self->applym($f, $quoted_args, $a);
        }
        elsif ($tag_name eq "cont") {
            # XXX: Skipping `okstack`/`proper` check for now
            my $s2 = $self->car($rest);
            my $r2 = $self->car($self->cdr($rest));
            $self->applycont($s2, $r2, $args);
        }
        else {
            my $virfns = $self->cdr($self->{globals}->get_kv("virfns"));
            my $it;
            if ($it = get($tag, $virfns)) {
                my $cdr_it = $self->cdr($it);
                my @stack;
                while (!is_nil($args)) {
                    push @stack, $self->car($args);
                    $args = $self->cdr($args);
                }
                my $quoted_args = SYMBOL_NIL;
                while (@stack) {
                    my $arg = pop(@stack);
                    $quoted_args = make_pair(
                        make_pair(
                            make_symbol("quote"),
                            make_pair(
                                $arg,
                                SYMBOL_NIL,
                            ),
                        ),
                        $quoted_args,
                    );
                }
                my $f_and_quoted_args = make_pair(
                    $f,
                    make_pair(
                        $quoted_args,
                        SYMBOL_NIL,
                    ),
                );
                my $fu = $self->fut(
                    <<'FUT',
                        (fn (s r m)
                          (mev (cons (list e a) s) r m))
FUT
                    sub {
                        my $virfn_result = pop @{$self->{r}};
                        push @{$self->{s}}, [$virfn_result, $a];
                    },
                );
                push @{$self->{s}}, $fu;
                $self->applyf($cdr_it, $f_and_quoted_args, $a);
            }
            else {
                die "'unapplyable\n";
            }
        }
    }
}

# (loc (is car) (f args a s r m)
#   (mev (cdr s) (cons (list (car args) 'a) r) m))
#
# (loc (is cdr) (f args a s r m)
#   (mev (cdr s) (cons (list (car args) 'd) r) m))
sub findlocfn {
    my ($self, $f, $args) = @_;

    if (is_pair($f)
        && is_symbol_of_name($self->car($f), "lit")
        && is_symbol_of_name($self->car($self->cdr($f)), "prim")) {
        my $caddr_f = $self->car($self->cdr($self->cdr($f)));
        if (is_symbol_of_name($caddr_f, "car")) {
            return make_pair(
                $self->car($args),
                make_pair(
                    make_symbol("a"),
                    SYMBOL_NIL,
                ),
            );
        }
        elsif (is_symbol_of_name($caddr_f, "cdr")) {
            return make_pair(
                $self->car($args),
                make_pair(
                    make_symbol("d"),
                    SYMBOL_NIL,
                ),
            );
        }
    }
    elsif (is_pair($f)
        && is_symbol_of_name($self->car($f), "lit")
        && is_symbol_of_name($self->car($self->cdr($f)), "tab")) {
        my $cell = $self->tabloc($f, $self->car($args));
        return make_pair(
            $cell,
            make_pair(
                make_symbol("d"),
                SYMBOL_NIL,
            ),
        );
    }
    return;
}

sub tabloc {
    my ($self, $tab, $key) = @_;

    my $kvs = $self->cdr($self->cdr($tab));
    ELEM:
    while (!is_nil($kvs)) {
        my $kv = $self->car($kvs);
        my @stack = [$self->car($kv), $key];
        while (@stack) {
            my ($v0, $v1) = @{pop(@stack)};
            if (!is_pair($v0) || !is_pair($v1)) {
                if (!atoms_are_identical($v0, $v1)) {
                    $kvs = $self->cdr($kvs);
                    next ELEM;
                }
            }
            else {
                push @stack, [$self->cdr($v0), $self->cdr($v1)];
                push @stack, [$self->car($v0), $self->car($v1)];
            }
        }
        return $kv;
    }
    my $cell = make_pair(
        $key,
        SYMBOL_NIL,
    );
    $self->xdr(
        $self->cdr($tab),
        make_pair($cell, $self->cdr($self->cdr($tab)))
    );
    return $cell;
}

# (def applyprim (f args s r m)
#   (aif (some [mem f _] prims)
#        (if (udrop (cdr it) args)
#            (sigerr 'overargs s r m)
#            (with (a (car args)
#                   b (cadr args))
#              (eif v (case f
#                       id   (id a b)
#                       join (join a b)
#                       car  (car a)
#                       cdr  (cdr a)
#                       type (type a)
#                       xar  (xar a b)
#                       xdr  (xdr a b)
#                       sym  (sym a)
#                       nom  (nom a)
#                       wrb  (wrb a b)
#                       rdb  (rdb a)
#                       ops  (ops a b)
#                       cls  (cls a)
#                       stat (stat a)
#                       coin (coin)
#                       sys  (sys a))
#                     (sigerr v s r m)
#                     (mev s (cons v r) m))))
#        (sigerr 'unknown-prim s r m)))
sub applyprim {
    my ($self, $f, $args) = @_;

    my $name = symbol_name($f);
    my $_a = $self->car($args);
    my $_b = $self->car($self->cdr($args));

    my $v = $self->{primitives}->call($name, $_a, $_b);
    push @{$self->{r}}, $v;
}

# (def applyclo (parms args env body s r m)
#   (mev (cons (fu (s r m)
#                (pass parms args env s r m))
#              (fu (s r m)
#                (mev (cons (list body (car r)) s)
#                     (cdr r)
#                     m))
#              s)
#        r
#        m))
sub applyclo {
    my ($self, $parms, $args, $env, $body) = @_;

    my $fu1 = $self->fut(
        <<'FUT',
            (fn (s r m)
              (pass parms args env s r m))
FUT
        sub {
            $self->pass($parms, $args, $env);
        },
    );
    my $fu2 = $self->fut(
        <<'FUT',
            (fn (s r m)
              (mev (cons (list body (car r)) s)
                   (cdr r)
                   m))
FUT
        sub {
            my $car_r = pop @{$self->{r}};
            push @{$self->{s}}, [
                $body,
                $car_r,
            ];
        },
    );
    push @{$self->{s}}, $fu2, $fu1;
}

# (def pass (pat arg env s r m)
#   (let ret [mev s (cons _ r) m]
#     (if (no pat)       (if arg
#                            (sigerr 'overargs s r m)
#                            (ret env))
#         (literal pat)  (sigerr 'literal-parm s r m)
#         (variable pat) (ret (cons (cons pat arg) env))
#         (caris pat t)  (typecheck (cdr pat) arg env s r m)
#         (caris pat o)  (pass (cadr pat) arg env s r m)
#                        (destructure pat arg env s r m))))
sub pass {
    my ($self, $pat, $arg, $env) = @_;

    if (is_nil($pat)) {
        # XXX: skipping the `'overargs` case for now
        push @{$self->{r}}, $env;
    }
    # XXX: skipping the literal case for now
    elsif ($self->variable($pat)) {
        push @{$self->{r}}, make_pair(make_pair($pat, $arg), $env);
    }
    elsif (is_pair($pat) && is_symbol_of_name(pair_car($pat), "t")) {
        $self->typecheck(pair_cdr($pat), $arg, $env);
    }
    elsif (is_pair($pat) && is_symbol_of_name(pair_car($pat), "o")) {
        $self->pass($self->car(pair_cdr($pat)), $arg, $env);
    }
    else {
        $self->destructure($pat, $arg, $env);
    }
}

# (def typecheck ((var f) arg env s r m)
#   (mev (cons (list (list f (list 'quote arg)) env)
#              (fu (s r m)
#                (if (car r)
#                    (pass var arg env s (cdr r) m)
#                    (sigerr 'mistype s r m)))
#              s)
#        r
#        m))
sub typecheck {
    my ($self, $var_f, $arg, $env) = @_;
    my $var = $self->car($var_f);
    my $f = $self->car($self->cdr($var_f));

    my $fu = $self->fut(
        <<'FUT',
            (fn (s r m)
              (if (car r)
                  (pass var arg env s (cdr r) m)
                  (sigerr 'mistype s r m)))
FUT
        sub {
            if (!is_nil(pop(@{$self->{r}}))) {
                $self->pass($var, $arg, $env);
            }
            else {
                die "'mistype\n";
            }
        },
    );
    push @{$self->{s}}, $fu, [
        make_pair(
            $f,
            make_pair(
                make_pair(
                    make_symbol("quote"),
                    make_pair(
                        $arg,
                        SYMBOL_NIL,
                    ),
                ),
                SYMBOL_NIL,
            ),
        ),
        $env,
    ];
}

# (def destructure ((p . ps) arg env s r m)
#   (if (no arg)   (if (caris p o)
#                      (mev (cons (list (caddr p) env)
#                                 (fu (s r m)
#                                   (pass (cadr p) (car r) env s (cdr r) m))
#                                 (fu (s r m)
#                                   (pass ps nil (car r) s (cdr r) m))
#                                 s)
#                           r
#                           m)
#                      (sigerr 'underargs s r m))
#       (atom arg) (sigerr 'atom-arg s r m)
#                  (mev (cons (fu (s r m)
#                               (pass p (car arg) env s r m))
#                             (fu (s r m)
#                               (pass ps (cdr arg) (car r) s (cdr r) m))
#                             s)
#                       r
#                       m)))
sub destructure {
    my ($self, $ps, $arg, $env) = @_;
    my $p = pair_car($ps);
    $ps = pair_cdr($ps);

    if (is_nil($arg)) {
        if (is_pair($p) && is_symbol_of_name(pair_car($p), "o")) {
            my $fu1 = $self->fut(
                <<'FUT',
                    (fn (s r m)
                      (pass (cadr p) (car r) env s (cdr r) m))
FUT
                sub {
                    $self->pass(
                        $self->car(pair_cdr($p)),
                        pop(@{$self->{r}}),
                        $env
                    );
                },
            );
            my $fu2 = $self->fut(
                <<'FUT',
                    (fn (s r m)
                      (pass ps nil (car r) s (cdr r) m))
FUT
                sub {
                    $self->pass($ps, SYMBOL_NIL, pop(@{$self->{r}}));
                },
            );
            push @{$self->{s}}, $fu2, $fu1, [
                $self->car($self->cdr(pair_cdr($p))),
                $env,
            ];
        }
        else {
            die "'underargs\n";
        }
    }
    elsif (!is_pair($arg)) {
        die "'atom-arg\n";
    }
    else {
        my $fu1 = $self->fut(
            <<'FUT',
                (fn (s r m)
                  (pass p (car arg) env s r m))
FUT
            sub {
                $self->pass($p, pair_car($arg), $env);
            },
        );
        my $fu2 = $self->fut(
            <<'FUT',
                (fn (s r m)
                  (pass ps (cdr arg) (car r) s (cdr r) m))
FUT
            sub {
                my $env = pop @{$self->{r}};
                $self->pass($ps, pair_cdr($arg), $env);
            },
        );
        push @{$self->{s}}, $fu2, $fu1;
    }
}

# (def applycont (s2 r2 args s r m)
#   (if (or (no args) (cdr args))
#       (sigerr 'wrong-no-args s r m)
#       (mev (append (keep [and (protected _) (no (mem _ s2 id))]
#                          s)
#                    s2)
#            (cons (car args) r2)
#            m)))
sub applycont {
    my ($self, $s2, $r2, $args) = @_;

    # XXX: skipping `args` error handling for now

    my %mem_s2;
    my $s2_copy = $s2;
    while (!is_nil($s2_copy)) {
        $mem_s2{$s2_copy} = 1;
        $s2_copy = $self->cdr($s2_copy);
    }

    my $smark = $self->cdr($self->{globals}->get_kv("smark"));

    # (def protected (x)
    #   (some [begins (car x) (list smark _) id]
    #         '(bind prot)))
    my $protected = sub {
        my $e = $_->[0];
        my $cdr;
        return is_pair($e)
            && are_identical($self->car($e), $smark)
            && is_pair($cdr = $self->cdr($e))
            && (is_symbol_of_name($self->car($cdr), "bind")
                || is_symbol_of_name($self->car($cdr), "prot"));
    };

    my @kept_s = grep {
        $protected->($_) && !$mem_s2{$_}
    } @{$self->{s}};
    @{$self->{s}} = ();
    while (!is_nil($s2)) {
        my $entry = $self->car($s2);
        my $e = $self->car($entry);
        my $a = $self->car($self->cdr($entry));
        unshift @{$self->{s}}, [$e, $a];
        $s2 = $self->cdr($s2);
    }
    unshift @{$self->{s}}, @kept_s;

    @{$self->{r}} = ();
    while (!is_nil($r2)) {
        my $value = $self->car($r2);
        unshift @{$self->{r}}, $value;
        $r2 = $self->cdr($r2);
    }
    push @{$self->{r}}, $self->car($args);
}

=head1 AUTHOR

Carl Mäsak, C<< <carl at masak.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-language-bel at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Language-Bel>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Language::Bel


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Language-Bel>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Language-Bel>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Language-Bel>

=item * Search CPAN

L<https://metacpan.org/release/Language-Bel>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2019-2021 by Carl Mäsak.

This program is released under the following license:

  gpl_3


=cut

1; # End of Language::Bel
