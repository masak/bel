package Language::Bel::Interpreter;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_char
    is_pair
    is_nil
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
);
use Language::Bel::Primitives qw(
    PRIMITIVES
);
use Language::Bel::Primitives qw(
    _id
    prim_car
    prim_cdr
    PRIM_FN
);
use Language::Bel::Reader qw(
    _read
);
use Language::Bel::Expander::Bquote qw(
    _bqexpand
);
use Language::Bel::Interpreter::Smark qw(
    is_smark
    is_smark_of_type
    make_smark_of_type
);

my @DECLARATIONS;
{
    my $para = "";
    my $add_declaration = sub {
        $para =~ s/\s+$//;
        push @DECLARATIONS, $para;
        $para = "";
    };
    my $accumulate_line = sub {
        my ($line) = @_;

        $para .= $line;
    };
    while (<Language::Bel::Interpreter::DATA>) {
        s/^\s+//;
        if ($_ eq "") {
            $add_declaration->();
        }
        else {
            $accumulate_line->($_);
        }
    }
    if ($para ne "") {
        $add_declaration->();
    }
}

sub new {
    my ($class, $options_ref) = @_;
    my $self = {
        ref($options_ref) eq "HASH" ? %$options_ref : (),
    };

    $self = bless($self, $class);
    if (!defined($self->{g})) {
        $self->{globals_hash} = {};
        $self->{g} = SYMBOL_NIL;

        for my $prim_name (keys(%{PRIMITIVES()})) {
            $self->set($prim_name, PRIMITIVES->{$prim_name});
        }

        for my $declaration (@DECLARATIONS) {
            my $ast = _read($declaration);
            next
                if is_nil($ast);   # `;` comment
            die "Malformed global declaration\n"
                unless is_pair($ast);

            my $car_ast = prim_car($ast);
            die "First element of list is not a symbol"
                unless is_symbol($car_ast);

            my $name = symbol_name(prim_car(prim_cdr($ast)));
            my $cddr_ast = prim_cdr(prim_cdr($ast));
            my $new_ast;

            if (symbol_name($car_ast) eq "def") {
                # (From bellanguage.txt)
                #
                # In the source I try not to use things before I've defined
                # them, but I've made a handful of exceptions to make the code
                # easier to read.
                #
                # When you see
                #
                # (def n p e)
                #
                # treat it as an abbreviation for
                #
                # (set n (lit clo nil p e))

                $new_ast = make_pair(
                    make_symbol("lit"),
                    make_pair(
                        make_symbol("clo"),
                        make_pair(
                            SYMBOL_NIL,
                            $cddr_ast,
                        ),
                    ),
                );
            }
            elsif (symbol_name($car_ast) eq "mac") {
                # and when you see
                #
                # (mac n p e)
                #
                # treat it as an abbreviation for
                #
                # (set n (lit mac (lit clo nil p e)))

                $new_ast = make_pair(
                    make_symbol("lit"),
                    make_pair(
                        make_symbol("mac"),
                        make_pair(
                            make_pair(
                                make_symbol("lit"),
                                make_pair(
                                    make_symbol("clo"),
                                    make_pair(
                                        SYMBOL_NIL,
                                        $cddr_ast,
                                    ),
                                ),
                            ),
                            SYMBOL_NIL,
                        ),
                    ),
                );
            }
            elsif (symbol_name($car_ast) eq "set") {
                $new_ast = prim_car($cddr_ast);
            }
            else {
                die "Unrecognized: $declaration";
            }

            $self->set($name, $self->eval_ast(_bqexpand($new_ast)));
        }
    }

    return $self;
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

        if (is_nil($es) eq "nil") {
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

    # XXX: skipping `inwhere` case for now
    my $it = $self->lookup($v, $a);
    if (is_pair($it)) {
        push @{$self->{r}}, pair_cdr($it);
    }
    else {
        my $name = is_symbol($v)
            ? symbol_name($v)
            : "<not a symbol>";
        die "('unboundb $name)\n";
    }
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
            my $es2 = pair_cdr($e);

            my $fu2 = fut(sub {
                my $args = SYMBOL_NIL;
                while (!is_nil($es2)) {
                    $args = make_pair(pop(@{$self->{r}}), $args);
                    $es2 = pair_cdr($es2);
                }

                if ($self->is_global_value($op, "err")) {
                    # XXX: Need to do proper parameter handling here
                    die symbol_name(prim_car($args)), "\n";
                }
                else {
                    $self->applyf($op, $args, $a);
                }
            });

            push @{$self->{s}}, $fu2;
            my @unevaluated_arguments;
            while (!is_nil($es1)) {
                push @unevaluated_arguments, [pair_car($es1), $a];
                $es1 = pair_cdr($es1);
            }
            # We want to evaluate the arguments in the order `a b c`,
            # so we need to put them on expression stack in the order
            # `c b a`. That's why we use `@unevaluated_arguments` as
            # an intermediary, to reverse the order.
            push @{$self->{s}}, reverse(@unevaluated_arguments);
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
        my $car_f = pair_car($f);
        if (!is_symbol_of_name($car_f, "lit")) {
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

    # XXX: skipping `inwhere`/`locfns` for now
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
    if ($prim->{arity} == 1) {
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
    # XXX: skipping the `t` case for now
    elsif (is_pair($pat) && is_symbol_of_name(pair_car($pat), "o")) {
        $self->pass(prim_car(pair_cdr($pat)), $arg, $env);
    }
    else {
        $self->destructure($pat, $arg, $env);
    }
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
    # XXX: skipping the `(atom arg)` case for now
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

sub ast_to_string {
    my ($self, $ast) = @_;

    if (is_symbol($ast)) {
        my $name = symbol_name($ast);
        return $name;
    }
    elsif (is_pair($ast)) {
        my @fragments = ("(");
        my $first_elem = 1;
        while (is_pair($ast)) {
            if (!$first_elem) {
                push @fragments, " ";
            }
            push @fragments, $self->ast_to_string(pair_car($ast));
            $ast = pair_cdr($ast);
            $first_elem = "";
        }
        if (!is_nil($ast)) {
            push @fragments, " . ";
            push @fragments, $self->ast_to_string($ast);
        }
        push @fragments, ")";
        return join("", @fragments);
    }
    else {
        die "unhandled: not a symbol";
    }
}

sub set {
    my ($self, $name, $value) = @_;

    $self->{globals_hash}{$name} = $value;
    $self->{g} = make_pair(
        make_pair(make_symbol($name), $value),
        $self->{g},
    );
}

1;
__DATA__
(def no (x)
  (id x nil))

(def atom (x)
  (no (id (type x) 'pair)))

(def all (f xs)
  (if (no xs)      t
      (f (car xs)) (all f (cdr xs))
                   nil))

(def some (f xs)
  (if (no xs)      nil
      (f (car xs)) xs
                   (some f (cdr xs))))

(def reduce (f xs)
  (if (no (cdr xs))
      (car xs)
      (f (car xs) (reduce f (cdr xs)))))

(def cons args
  (reduce join args))

(def append args
  (if (no (cdr args)) (car args)
      (no (car args)) (apply append (cdr args))
                      (cons (car (car args))
                            (apply append (cdr (car args))
                                          (cdr args)))))

(def snoc args
  (append (car args) (cdr args)))

(def list args
  (append args nil))

(def map (f . ls)
  (if (no ls)       nil
      (some no ls)  nil
      (no (cdr ls)) (cons (f (car (car ls)))
                          (map f (cdr (car ls))))
                    (cons (apply f (map car ls))
                          (apply map f (map cdr ls)))))

(mac fn (parms . body)
  (if (no (cdr body))
    `(list 'lit 'clo scope ',parms ',(car body))
    `(list 'lit 'clo scope ',parms '(do ,@body))))

(set vmark (join))

(def uvar ()
  (list vmark))

(mac do args
  (reduce (fn (x y)
            (list (list 'fn (uvar) y) x))
          args))

(mac let (parms val . body)
  `((fn (,parms) ,@body) ,val))

(mac macro args
  `(list 'lit 'mac (fn ,@args)))

(mac set (v e)
  `(do
     (xdr globe (cons (cons ',v ,e) (cdr globe)))
     t))

(mac def (n . rest)
  `(set ,n (fn ,@rest)))

(mac mac (n . rest)
  `(set ,n (macro ,@rest)))

(mac or args
  (if (no args)
      nil
      (let v (uvar)
        `(let ,v ,(car args)
           (if ,v ,v (or ,@(cdr args)))))))

(mac and args
  (reduce (fn es (cons 'if es))
          (or args '(t))))

(def = args
  (if (no (cdr args))  t
      (some atom args) (all [id _ (car args)] (cdr args))
                       (and (apply = (map car args))
                            (apply = (map cdr args)))))

(def symbol (x) (= (type x) 'symbol))

(def pair   (x) (= (type x) 'pair))

(def char   (x) (= (type x) 'char))

; not doing `stream` right now; waiting until we have streams

(def proper (x)
  (or (no x)
      (and (pair x) (proper (cdr x)))))

(def string (x)
  (and (proper x) (all char x)))

(def mem (x ys (o f =))
  (some [f _ x] ys))

(def in (x . ys)
  (mem x ys))

(def cadr  (x) (car (cdr x)))

(def cddr  (x) (cdr (cdr x)))

(def caddr (x) (car (cddr x)))

(mac case (expr . args)
  (if (no (cdr args))
      (car args)
      (let v (uvar)
        `(let ,v ,expr
           (if (= ,v ',(car args))
               ,(cadr args)
               (case ,v ,@(cddr args)))))))

(mac iflet (var . args)
  (if (no (cdr args))
      (car args)
      (let v (uvar)
        `(let ,v ,(car args)
           (if ,v
               (let ,var ,v ,(cadr args))
               (iflet ,var ,@(cddr args)))))))

(mac aif args
  `(iflet it ,@args))

(def find (f xs)
  (aif (some f xs) (car it)))

(def begins (xs pat (o f =))
  (if (no pat)               t
      (atom xs)              nil
      (f (car xs) (car pat)) (begins (cdr xs) (cdr pat) f)
                             nil))

(def caris (x y (o f =))
  (begins x (list y) f))

(def hug (xs (o f list))
  (if (no xs)       nil
      (no (cdr xs)) (list (f (car xs)))
                    (cons (f (car xs) (cadr xs))
                          (hug (cddr xs) f))))

(mac with (parms . body)
  (let ps (hug parms)
    `((fn ,(map car ps) ,@body)
      ,@(map cadr ps))))

(def keep (f xs)
  (if (no xs)      nil
      (f (car xs)) (cons (car xs) (keep f (cdr xs)))
                   (keep f (cdr xs))))

(def rem (x ys (o f =))
  (keep [no (f _ x)] ys))

(def get (k kvs (o f =))
  (find [f (car _) k] kvs))

(def put (k v kvs (o f =))
  (cons (cons k v)
        (rem k kvs (fn (x y) (f (car x) y)))))

(def rev (xs)
  (if (no xs)
      nil
      (snoc (rev (cdr xs)) (car xs))))

(def snap (xs ys (o acc))
  (if (no xs)
      (list acc ys)
      (snap (cdr xs) (cdr ys) (snoc acc (car ys)))))

(def udrop (xs ys)
  (cadr (snap xs ys)))

(def idfn (x)
  x)

(def is (x)
  [= _ x])

; skipping `eif`, `onerr`, `safe`; these require overriding `err` dynamically, and `ccc`

; skipping `literal`, `variable`; very low-yield without the evaluator

(def isa (name)
  [begins _ `(lit ,name) id])

; skipping the evaluator for now

(def function (x)
  (find [(isa _) x] '(prim clo)))

(def con (x)
  (fn args x))

; we are here currently, implementing things

(def err args)

(mac comma args
  '(err 'comma-outside-backquote))

(mac comma-at args
  '(err 'comma-at-outside-backquote))

(mac splice args
  '(err 'comma-at-outside-list))
