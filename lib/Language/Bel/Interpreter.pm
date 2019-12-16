package Language::Bel::Interpreter;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_char
    is_pair
    is_symbol
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

my @DECLARATIONS;
{
    # XXX: I'm running this on Windows, but I need to write a portable
    # solution that also considers Unix/Linux newlines.
    local $/ = "\r\n\r\n";  # paragraph mode
    while (<Language::Bel::Interpreter::DATA>) {
        s/(\r\n){1,2}$//;
        push @DECLARATIONS, $_;
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
            my ($name, $source);

            # XXX: Just hunting for the next closing parenthesis, like this
            # regex does, it too simplistic for the general case. It'll work
            # for a while, but it'll fail once we get to `mem`:
            #
            #     (def mem (x ys (o f =))
            #       (some [f _ x] ys))
            #
            # Luckily there's a much better way; we should read the expression
            # and then do the replacement on the (cons pair) AST. This will
            # require writing a small pattern matcher; it doesn't need to be
            # so fancy for this use, just enough to do the replacements we
            # need for the globals.
            if ($declaration =~ /^\(def (\S+) (\w+|\([^)]*\))\s*(.*)\)$/ms) {
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

                $name = $1;
                my ($p, $e) = ($2, $3);
                $e ||= "nil";
                $source = "(lit clo nil $p $e)";
            }
            elsif ($declaration =~ /^\(mac (\S+) (\w+|\([^)]*\))\s+(.+)\)$/ms) {
                # and when you see
                #
                # (mac n p e)
                #
                # treat it as an abbreviation for
                #
                # (set n (lit mac (lit clo nil p e)))

                $name = $1;
                my ($p, $e) = ($2, $3);
                $source = "(lit mac (lit clo nil $p $e))";
            }
            elsif ($declaration =~ /\(set (\S+) (.+)\)/ms) {
                ($name, $source) = ($1, $2);
            }
            else {
                die "Unrecognized: $declaration";
            }

            my $ast = _bqexpand(_read($source));
            $self->set($name, $self->eval_ast($ast));
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

        if (is_symbol($es) && symbol_name($es) eq "nil") {
            push @{$interpreter->{r}}, SYMBOL_NIL;
        }
        else {
            my $cdr_es = prim_cdr($es);
            if (!is_symbol($cdr_es) || symbol_name($cdr_es) ne "nil") {
                my $fu = sub {
                    if2($interpreter, prim_cdr($es), $a);
                };
                push @{$interpreter->{s}}, $fu;
            }
            push @{$interpreter->{s}}, [prim_car($es), $a];
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
    my $e = !is_symbol($car_r) || symbol_name($car_r) ne "nil"
        ? prim_car($es)
        : make_pair(make_symbol("if"), prim_cdr($es));
    push @{$interpreter->{s}}, [$e, $a];
}

# (def ev (((e a) . s) r m)
#   (aif (literal e)            (mev s (cons e r) m)
#        (variable e)           (vref e a s r m)
#        (no (proper e))        (sigerr 'malformed s r m)
#        (get (car e) forms id) ((cdr it) (cdr e) a s r m)
#                               (evcall e a s r m)))
sub ev {
    my ($self) = @_;

    my $e_a = pop @{$self->{s}};
    # the following corresponds to the `fut` case of `evmark`
    if (ref($e_a) eq "CODE") {
        $e_a->();
    }
    else {
        my $e = $e_a->[0];
        my $a = $e_a->[1];

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
        # XXX: skipping `proper` check for now
        elsif (my $form = $is_form->($e)) {
            $form->($self, pair_cdr($e), $a);
        }
        else {
            $self->evcall($e, $a);
        }
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
        my ($e) = @_;

        return unless is_symbol($e);

        my $name = symbol_name($e);
        return $name eq "t" || $name eq "nil" ||
            $name eq "o" || $name eq "apply";
    };

    my $is_lit = sub {
        my ($e) = @_;

        return unless is_pair($e);

        my $car = pair_car($e);
        return unless is_symbol($car);

        return symbol_name($car) eq "lit";
    };

    return (
        $is_self_evaluating->($e) ||
        is_char($e) ||
        # XXX: skipping is_stream case for now
        $is_lit->($e)
        # XXX: skipping string case for now
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

    return is_pair($e)
        ? $self->is_global_value(pair_car($e), "vmark")
        : !literal($e);
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
            && is_symbol(pair_cdr($first))
            && symbol_name(pair_cdr($first)) eq "nil"
            && is_pair($second)
            && _id($first, $second);
    };

    while (!is_symbol($kvs) || symbol_name($kvs) ne "nil") {
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

    # XXX: skipping `binding` case for now
    return get($e, $a)
        || get($e, $self->{g})
        || (is_symbol($e)
            && symbol_name($e) eq "scope"
            && make_pair($e, $a))
        || (is_symbol($e)
            && symbol_name($e) eq "globe"
            && make_pair($e, $self->{g}))
        || SYMBOL_NIL;
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

    my $fu1 = sub {
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
                && is_symbol(prim_car($v))
                && symbol_name(prim_car($v)) eq "lit"
                && is_pair(prim_cdr($v))
                && is_symbol(prim_car(prim_cdr($v)))
                && symbol_name(prim_car(prim_cdr($v))) eq "mac";
        };

        if ($isa_mac->($op)) {
            $self->applym($op, $es1, $a);
        }
        else {
            # We're consuming `es` twice, once in each fut.
            # So we capture it twice.
            my $es2 = pair_cdr($e);

            my $fu2 = sub {
                my $args = SYMBOL_NIL;
                while (!is_symbol($es2) || symbol_name($es2) ne "nil") {
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
            };

            push @{$self->{s}}, $fu2;
            my @unevaluated_arguments;
            while (!is_symbol($es1) || symbol_name($es1) ne "nil") {
                push @unevaluated_arguments, [pair_car($es1), $a];
                $es1 = pair_cdr($es1);
            }
            # We want to evaluate the arguments in the order `a b c`,
            # so we need to put them on expression stack in the order
            # `c b a`. That's why we use `@unevaluated_arguments` as
            # an intermediary, to reverse the order.
            push @{$self->{s}}, reverse(@unevaluated_arguments);
        }
    };
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
    my $fu = sub {
        my $macro_expansion = pop @{$self->{r}};
        push @{$self->{s}}, [$macro_expansion, $a];
    };
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

    if (is_symbol($f) && symbol_name($f) eq "apply") {
        my $apply_op = prim_car($args);
        my $cdr_args = prim_cdr($args);
        my $reduce_expr = [
            make_pair(
                make_symbol("reduce"),
                make_pair(
                    make_symbol("join"),
                    make_pair(
                        make_pair(
                            make_symbol("quote"),
                            make_pair(
                                $cdr_args,
                                SYMBOL_NIL,
                            ),
                        ),
                        SYMBOL_NIL,
                    ),
                ),
            ),
            SYMBOL_NIL,     # not `$a`; we're not running `reduce join`
                            # in the expression's environment
        ];

        my $fu = sub {
            my $apply_args = pop(@{$self->{r}});
            $self->applyf($apply_op, $apply_args, $a);
        };

        push @{$self->{s}}, $fu, $reduce_expr;
    }
    else {
        my $car_f = pair_car($f);
        if (!is_symbol($car_f) || symbol_name($car_f) ne "lit") {
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

    my $fu1 = sub {
        $self->pass($parms, $args, $env);
    };
    my $fu2 = sub {
        my $car_r = pop @{$self->{r}};
        push @{$self->{s}}, [
            $body,
            $car_r,
        ];
    };
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

    if (is_symbol($pat) && symbol_name($pat) eq "nil") {
        # XXX: skipping the `'overargs` case for now
        push @{$self->{r}}, $env;
    }
    # XXX: skipping the literal case for now
    elsif ($self->variable($pat)) {
        push @{$self->{r}}, make_pair(make_pair($pat, $arg), $env);
    }
    # XXX: skipping the `t` case for now
    # XXX: skipping the `o` case for now
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

    if (is_symbol($arg) && symbol_name($arg) eq "nil") {
        # XXX: skipping the `(caris p o)` case for now
        die "'underargs\n";
    }
    # XXX: skipping the `(atom arg)` case for now
    else {
        my $fu1 = sub {
            $self->pass($p, pair_car($arg), $env);
        };
        my $fu2 = sub {
            my $env = pop @{$self->{r}};
            $self->pass($ps, pair_cdr($arg), $env);
        };
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
        if (!is_symbol($ast) || symbol_name($ast) ne "nil") {
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

(def err args)

(mac comma args
  '(err 'comma-outside-backquote))

(mac comma-at args
  '(err 'comma-at-outside-backquote))

(mac splice args
  '(err 'comma-at-outside-list))
