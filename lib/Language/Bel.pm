package Language::Bel;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_char
    is_fastfunc
    is_nil
    is_pair
    is_string
    is_symbol
    is_symbol_of_name
    make_pair
    make_symbol
    pair_car
    pair_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
    SYMBOL_T
);
use Language::Bel::Primitives qw(
    PRIMITIVES
);
use Language::Bel::Primitives qw(
    _id
    prim_car
    prim_cdr
    prim_type
    prim_xdr
    PRIM_FN
);
use Language::Bel::Reader qw(
    read_whole
);
use Language::Bel::Expander::Bquote qw(
    _bqexpand
);
use Language::Bel::Smark qw(
    is_smark
    is_smark_of_type
    make_smark_of_type
);
use Language::Bel::Globals qw(
    GLOBALS
);
use Language::Bel::Printer qw(
    _print
);

=head1 NAME

Language::Bel - An interpreter for Paul Graham's language Bel

=head1 VERSION

Version 0.35

=cut

our $VERSION = '0.35';

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
    if (!defined($self->{g})) {
        $self->{globals_hash} = GLOBALS;

        $self->{g} = SYMBOL_NIL;
        for my $name (keys(%{$self->{globals_hash}})) {
            my $value = GLOBALS->{$name};
            $self->{g} = make_pair(
                make_pair(make_symbol($name), $value),
                $self->{g},
            );
        }
    }
    if (!defined($self->{call})) {
        $self->{call} = sub {
            my ($fn, @args) = @_;

            if (is_fastfunc($fn)) {
                return $fn->apply($self->{call}, @args);
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
        };
    }

    return $self;
}

=head2 eval

Evaluates an expression, passed in as a string of Bel code.

=cut

sub eval {
    my ($self, $expr) = @_;

    my $ast = _bqexpand(read_whole($expr));
    my $result = $self->eval_ast($ast);
    my $result_string = _print($result);

    my $output = $self->{output};
    if (ref($output) eq "CODE") {
        $output->($result_string);
    }

    return;
}

# (def bel (e (o g globe))
#   (ev (list (list e nil))
#       nil
#       (list nil g)))
sub eval_ast {
    my ($self, $ast) = @_;

    $self->{s} = [[$ast, SYMBOL_NIL]];
    $self->{r} = [];

    while (@{$self->{s}}) {
        $self->ev();
    }
    return $self->{r}[-1];
}

sub fut {
    my ($sub) = @_;

    return [make_smark_of_type("fut", $sub), SYMBOL_NIL];
}

my %forms = (
    # (form quote ((e) a s r m)
    #   (mev s (cons e r) m))
    quote => sub {
        my ($interpreter, $es, $a) = @_;

        # XXX: skipping $es sanity check for now
        my $e = pair_car($es);
        push @{$interpreter->{r}}, $e;
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
        my ($interpreter, $es, $a) = @_;

        if (is_nil($es)) {
            push @{$interpreter->{r}}, SYMBOL_NIL;
        }
        else {
            my $cdr_es = prim_cdr($es);
            if (!is_nil($cdr_es)) {
                my $fu = fut(sub {
                    if2($interpreter, prim_cdr($es), $a);
                });
                push @{$interpreter->{s}}, $fu;
            }
            push @{$interpreter->{s}}, [prim_car($es), $a];
        }
    },

    # (form where ((e (o new)) a s r m)
    #   (mev (cons (list e a)
    #              (list (list smark 'loc new) nil)
    #              s)
    #        r
    #        m))
    where => sub {
        my ($interpreter, $e_new, $a) = @_;
        my $e = prim_car($e_new);
        my $new = prim_car(prim_cdr($e_new));

        push @{$interpreter->{s}}, [make_smark_of_type("loc", $new), SYMBOL_NIL];
        push @{$interpreter->{s}}, [$e, $a];
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
        my ($interpreter, $es, $a) = @_;

        # XXX: skipping $es sanity check for now
        my $v = prim_car($es);
        my $e1 = prim_car(prim_cdr($es));
        my $e2 = prim_car(prim_cdr(prim_cdr($es)));

        if ($interpreter->variable($v)) {
            my $fu = fut(sub {
                dyn2($interpreter, $v, $e2, $a);
            });
            push @{$interpreter->{s}}, $fu, [$e1, $a];
        }
        else {
            die "'cannot-bind\n";
        }
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
    my ($interpreter, $es, $a) = @_;

    my $car_r = pop(@{$interpreter->{r}});
    my $e = !is_nil($car_r)
        ? prim_car($es)
        : make_pair(make_symbol("if"), prim_cdr($es));
    push @{$interpreter->{s}}, [$e, $a];
}

# (def dyn2 (v e2 a s r m)
#   (mev (cons (list e2 a)
#              (list (list smark 'bind (cons v (car r)))
#                    nil)
#              s)
#        (cdr r)
#        m))
sub dyn2 {
    my ($interpreter, $v, $e2, $a) = @_;

    my $car_r = pop(@{$interpreter->{r}});
    push @{$interpreter->{s}},
        [make_smark_of_type("bind", make_pair($v, $car_r)), SYMBOL_NIL],
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
    elsif (is_smark_of_type($e, "fut")) {
        $e->value()->();
    }
    elsif (is_smark_of_type($e, "bind")) {
        # do nothing; already popped it off the stack
    }
    elsif (is_smark_of_type($e, "loc")) {
        die "'unfindable\n";
    }
    elsif (is_smark($e)) {
        die "Unknown smark";
    }
    # XXX: skipping `loc`, `prot` for now
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

sub is_global_value {
    my ($self, $e, $global_name) = @_;

    my $global = $self->{globals_hash}{$global_name};
    return $global && _id($e, $global);
}

# (def variable (e)
#   (if (atom e)
#       (no (literal e))
#       (id (car e) vmark)))
sub variable {
    my ($self, $e) = @_;

    # Smarks are not pairs in this interpreter
    return if is_smark($e);

    return is_pair($e)
        ? $self->is_global_value(pair_car($e), "vmark")
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
    if ($it = inwhere($self->{s})) {
        my $car_inwhere = prim_car($it);
        if (is_pair($it = $self->lookup($v, $a))
            || !is_nil($car_inwhere) && ($it = $self->install_global($v))) {
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
    my ($s_ref) = @_;

    my $smark;
    return @$s_ref
        && is_smark_of_type($smark = $s_ref->[-1][0], "loc")
        && make_pair($smark->value(), SYMBOL_NIL);
}

#                       (let cell (cons v nil)
#                         (xdr g (cons cell (cdr g)))
#                         cell)))
sub install_global {
    my ($self, $v) = @_;

    my $cell = make_pair($v, SYMBOL_NIL);
    prim_xdr($self->{g}, make_pair(
        $cell,
        prim_cdr($self->{g}),
    ));

    return $cell;
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
            && _id($first, $second);
        return is_pair($first)
            && is_pair(pair_car($first))
            && is_nil(pair_cdr($first))
            && is_pair($second)
            && _id($first, $second);
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
        || get($e, $self->{g})
        || (is_symbol_of_name($e, "scope") && make_pair($e, $a))
        || (is_symbol_of_name($e, "globe") && make_pair($e, $self->{g}))
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

        next unless is_smark_of_type($e, "bind");
        my $smark_value = $e->value();
        next unless _id(pair_car($smark_value), $v);
        return $smark_value;
    }

    return;
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

    my $fu1 = fut(sub {
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

        my $es1 = pair_cdr($e);
        my $op = pop @{$self->{r}};

        my $isa_mac = sub {
            my ($v) = @_;

            return is_pair($v)
                && is_symbol_of_name(prim_car($v), "lit")
                && is_pair(prim_cdr($v))
                && is_symbol_of_name(prim_car(prim_cdr($v)), "mac");
        };

        if ($isa_mac->($op)) {
            $self->applym($op, $es1, $a);
        }
        else {
            # We're consuming `es` twice, once in each fut.
            # So we capture it twice.
            my $es2 = $es1;

            my $fu2 = fut(sub {
                my $args = SYMBOL_NIL;
                my @args;
                while (!is_nil($es2)) {
                    my $arg = pop(@{$self->{r}});
                    $args = make_pair($arg, $args);
                    unshift @args, $arg;
                    $es2 = pair_cdr($es2);
                }

                if ($self->is_global_value($op, "err")) {
                    # XXX: Need to do proper parameter handling here
                    die symbol_name(prim_car($args)), "\n";
                }
                elsif (is_fastfunc($op)) {
                    my $e;
                    if (inwhere($self->{s}) && $op->handles_where()) {
                        $e = $op->where_apply($self->{call}, @args);
                        if (!is_nil($e)) {
                            pop @{$self->{s}};  # get rid of the (smark 'loc)
                        }
                    }
                    else {
                        $e = $op->apply($self->{call}, @args);
                    }
                    push @{$self->{r}}, $e;
                }
                else {
                    $self->applyf($op, $args, $a);
                }
            });

            my @unevaluated_arguments;
            while (!is_nil($es1)) {
                push @unevaluated_arguments, [pair_car($es1), $a];
                $es1 = pair_cdr($es1);
            }
            # We want to evaluate the arguments in the order `a b c`,
            # so we need to put them on expression stack in the order
            # `c b a`. That's why we use `@unevaluated_arguments` as
            # an intermediary, to reverse the order.
            push @{$self->{s}}, $fu2, reverse(@unevaluated_arguments);
        }
    });
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

    my $mac_clo = prim_car(prim_cdr(prim_cdr($mac)));
    my $fu = fut(sub {
        my $macro_expansion = pop @{$self->{r}};
        push @{$self->{s}}, [$macro_expansion, $a];
    });
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
        my $apply_op = prim_car($args);
        my $it_arg = prim_cdr($args);
        my @stack;
        while (!is_nil($it_arg)) {
            push @stack, prim_car($it_arg);
            $it_arg = prim_cdr($it_arg);
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
    if (inwhere($self->{s}) && ($it = findlocfn($f, $args))) {
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
            my $env = pair_car($rest);
            my $parms = pair_car(pair_cdr($rest));
            my $body = pair_car(pair_cdr(pair_cdr($rest)));

            # XXX: skipping `okenv` and `okparms` checks for now
            $self->applyclo($parms, $args, $env, $body);
        }
        # XXX: skipping `mac` case for now
        # XXX: skipping `cont` case for now
        else {
            my $virfns = pair_cdr(get(make_symbol("virfns"), $self->{g}));
            my $it;
            if ($it = get($tag, $virfns)) {
                my $cdr_it = prim_cdr($it);
                my @stack;
                while (!is_nil($args)) {
                    push @stack, prim_car($args);
                    $args = prim_cdr($args);
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
                my $fu = fut(sub {
                    my $virfn_result = pop @{$self->{r}};
                    push @{$self->{s}}, [$virfn_result, $a];
                });
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
    my ($f, $args) = @_;

    if (is_pair($f)
        && is_symbol_of_name(prim_car($f), "lit")
        && is_symbol_of_name(prim_car(prim_cdr($f)), "prim")) {
        my $caddr_f = prim_car(prim_cdr(prim_cdr($f)));
        if (is_symbol_of_name($caddr_f, "car")) {
            return make_pair(
                prim_car($args),
                make_pair(
                    make_symbol("a"),
                    SYMBOL_NIL,
                ),
            );
        }
        elsif (is_symbol_of_name($caddr_f, "cdr")) {
            return make_pair(
                prim_car($args),
                make_pair(
                    make_symbol("d"),
                    SYMBOL_NIL,
                ),
            );
        }
    }
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
    my $_a = prim_car($args);
    my $_b = prim_car(prim_cdr($args));

    my $prim = PRIM_FN->{$name};
    # XXX: skipping the 'unknown-prim case for now
    my $fn = $prim->{fn};
    my $v;
    if ($prim->{arity} == 0) {
        $v = $fn->();
    }
    elsif ($prim->{arity} == 1) {
        $v = $fn->($_a);
    }
    elsif ($prim->{arity} == 2) {
        $v = $fn->($_a, $_b);
    }
    # XXX: skipping the `sigerr` case
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

    my $fu1 = fut(sub {
        $self->pass($parms, $args, $env);
    });
    my $fu2 = fut(sub {
        my $car_r = pop @{$self->{r}};
        push @{$self->{s}}, [
            $body,
            $car_r,
        ];
    });
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
        $self->pass(prim_car(pair_cdr($pat)), $arg, $env);
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
    my $var = prim_car($var_f);
    my $f = prim_car(prim_cdr($var_f));

    my $fu = fut(sub {
        if (!is_nil(pop(@{$self->{r}}))) {
            $self->pass($var, $arg, $env);
        }
        else {
            die "'mistype\n";
        }
    });
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
            my $fu1 = fut(sub {
                $self->pass(prim_car(pair_cdr($p)), pop(@{$self->{r}}), $env);
            });
            my $fu2 = fut(sub {
                $self->pass($ps, SYMBOL_NIL, pop(@{$self->{r}}));
            });
            push @{$self->{s}}, $fu2, $fu1, [
                prim_car(prim_cdr(pair_cdr($p))),
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
        my $fu1 = fut(sub {
            $self->pass($p, pair_car($arg), $env);
        });
        my $fu2 = fut(sub {
            my $env = pop @{$self->{r}};
            $self->pass($ps, pair_cdr($arg), $env);
        });
        push @{$self->{s}}, $fu2, $fu1;
    }
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

This software is Copyright (c) 2019 by Carl Mäsak.

This program is released under the following license:

  gpl_3


=cut

1; # End of Language::Bel
