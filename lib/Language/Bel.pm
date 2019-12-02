package Language::Bel;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_char
    is_pair
    is_symbol
    make_char
    make_pair
    make_symbol
    pair_car
    pair_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
    SYMBOL_QUOTE
    SYMBOL_T
);
use Language::Bel::Primitives qw(
    prim_car
    prim_cdr
    prim_id
    prim_join
    prim_type
    PRIM_FN
    PRIMITIVES
);

=head1 NAME

Language::Bel - An interpreter for Paul Graham's language Bel

=head1 VERSION

Version 0.11

=cut

our $VERSION = '0.11';

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

    return bless($self, $class);
}

=head2 eval

=cut

sub eval {
    my ($self, $expr) = @_;

    my $ast = _read($expr);
    my $result = $self->eval_ast($ast);
    my $result_string = $self->ast_to_string($result);

    my $output = $self->{output};
    if (ref($output) eq "CODE") {
        $output->($result_string);
    }

    return;
}

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

my $GLOBALS = SYMBOL_NIL;
sub add_global {
    my ($name, $value) = @_;

    $GLOBALS = make_pair(
        make_pair(make_symbol($name), $value),
        $GLOBALS,
    );
}

for my $prim_name (qw(car cdr id join type)) {
    add_global($prim_name, PRIMITIVES->{$prim_name});
}

add_global("no", _read("(lit clo nil (x) (id x nil))"));

add_global("atom", _read("(lit clo nil (x) (no (id (type x) 'pair)))"));

add_global("all", _read("
    (lit clo nil (f xs)
      (if (no xs)      t
          (f (car xs)) (all f (cdr xs))
                       nil))
"));

add_global("some", _read("
    (lit clo nil (f xs)
      (if (no xs)      nil
          (f (car xs)) xs
                       (some f (cdr xs))))
"));

add_global("reduce", _read("
    (lit clo nil (f xs)
      (if (no (cdr xs))
          (car xs)
          (f (car xs) (reduce f (cdr xs)))))
"));

add_global("cons", _read("
    (lit clo nil args
      (reduce join args))
"));

add_global("append", _read("
    (lit clo nil args
      (if (no (cdr args)) (car args)
          (no (car args)) (apply append (cdr args))
                          (cons (car (car args))
                                (apply append (cdr (car args))
                                              (cdr args)))))
"));

# (def bel (e (o g globe))
#   (ev (list (list e nil))
#       nil
#       (list nil g)))
sub eval_ast {
    my ($self, $ast) = @_;

    my $expr_stack = [[$ast, SYMBOL_NIL]];
    my $ret_stack = [];
    my $m = [[], $GLOBALS];

    while (@$expr_stack) {
        _ev($expr_stack, $ret_stack, $m);
    }
    return $ret_stack->[-1];
}

my %forms = (
    # (form quote ((e) a s r m)
    #   (mev s (cons e r) m))
    quote => sub {
        my ($es, $a, $s, $r, $m) = @_;

        # XXX: skipping $es sanity check for now
        my $e = pair_car($es);
        push @$r, $e;
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
        my ($es, $a, $s, $r, $m) = @_;

        if (is_symbol($es) && symbol_name($es) eq "nil") {
            push @$r, SYMBOL_NIL;
        }
        else {
            my $cdr_es = prim_cdr($es);
            if (!is_symbol($cdr_es) || symbol_name($cdr_es) ne "nil") {
                my $fu = sub {
                    my ($s, $r, $m) = @_;

                    _if2(prim_cdr($es), $a, $s, $r, $m);
                };
                push @$s, $fu;
            }
            push @$s, [prim_car($es), $a];
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
sub _if2 {
    my ($es, $a, $s, $r, $m) = @_;

    my $car_r = pop(@$r);
    my $e = !is_symbol($car_r) || symbol_name($car_r) ne "nil"
        ? prim_car($es)
        : make_pair(make_symbol("if"), prim_cdr($es));
    push @$s, [$e, $a];
}

# (def ev (((e a) . s) r m)
#   (aif (literal e)            (mev s (cons e r) m)
#        (variable e)           (vref e a s r m)
#        (no (proper e))        (sigerr 'malformed s r m)
#        (get (car e) forms id) ((cdr it) (cdr e) a s r m)
#                               (evcall e a s r m)))
sub _ev {
    my ($s, $r, $m) = @_;
    my $e_a = pop @$s;
    # the following corresponds to the `fut` case of `evmark`
    if (ref($e_a) eq "CODE") {
        $e_a->($s, $r, $m);
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

        if (_literal($e)) {
            push @$r, $e;
        }
        elsif (_variable($e)) {
            _vref($e, $a, $s, $r, $m);
        }
        # XXX: skipping `proper` check for now
        elsif (my $form = $is_form->($e)) {
            $form->(pair_cdr($e), $a, $s, $r, $m);
        }
        else {
            _evcall($e, $a, $s, $r, $m);
        }
    }
}

# (def literal (e)
#   (or (in e t nil o apply)
#       (in (type e) 'char 'stream)
#       (caris e 'lit)
#       (string e)))
sub _literal {
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

# (def variable (e)
#   (if (atom e)
#       (no (literal e))
#       (id (car e) vmark)))
sub _variable {
    my ($e) = @_;

    # XXX: skipping the vmark case for now
    return !is_pair($e) && !_literal($e);
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
sub _vref {
    my ($v, $a, $s, $r, $m) = @_;

    my $g = $m->[1];
    # XXX: skipping `inwhere` case for now
    my $it = _lookup($v, $a, $s, $g);
    if (is_pair($it)) {
        push @$r, pair_cdr($it);
    }
}

# (def lookup (e a s g)
#   (or (binding e s)
#       (get e a id)
#       (get e g id)
#       (case e
#         scope (cons e a)
#         globe (cons e g))))
sub _lookup {
    my ($e, $a, $s, $g) = @_;

    my $symbols_id = sub {
        my ($first, $second) = @_;

        return is_symbol($first)
            && is_symbol($second)
            && symbol_name($first) eq symbol_name($second);
    };

    # (def get (k kvs (o f =))
    #   (find [f (car _) k] kvs))
    my $get = sub {
        my ($k, $kvs) = @_;

        while (!is_symbol($kvs) || symbol_name($kvs) ne "nil") {
            my $kv = pair_car($kvs);
            my $key = pair_car($kv);

            if ($symbols_id->($key, $k)) {
                return $kv;
            }
            $kvs = pair_cdr($kvs);
        }
        return;
    };

    # XXX: skipping `binding` case for now
    return $get->($e, $a)
        || $get->($e, $g)
        # XXX: skipping the `scope globe` defaults for now
        || SYMBOL_NIL;
}

# (def evcall (e a s r m)
#   (mev (cons (list (car e) a)
#              (fu (s r m)
#                (evcall2 (cdr e) a s r m))
#              s)
#        r
#        m))
sub _evcall {
    my ($e, $a, $s, $r, $m) = @_;

    my $fu1 = sub {
        my ($s, $r, $m) = @_;

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

        # We're consuming `es` twice, once in each fut. So we capture it twice.
        my $es1 = pair_cdr($e);
        my $es2 = pair_cdr($e);
        my $op = pop @$r;

        # XXX: skipping `isa 'mac` check for now
        my $fu2 = sub {
            my ($s, $r, $m) = @_;

            my $args = SYMBOL_NIL;
            while (!is_symbol($es2) || symbol_name($es2) ne "nil") {
                $args = make_pair(pop(@$r), $args);
                $es2 = pair_cdr($es2);
            }

            _applyf($op, $args, $a, $s, $r, $m);
        };

        push @$s, $fu2;
        my @unevaluated_arguments;
        while (!is_symbol($es1) || symbol_name($es1) ne "nil") {
            push @unevaluated_arguments, [pair_car($es1), $a];
            $es1 = pair_cdr($es1);
        }
        # We want to evaluate the arguments in the order `a b c`, so we need
        # to put them on expression stack in the order `c b a`. That's why we
        # use `@unevaluated_arguments` as an intermediary, to reverse the
        # order.
        while (@unevaluated_arguments) {
            push @$s, pop(@unevaluated_arguments);
        }
    };
    push @$s, $fu1, [pair_car($e), $a];
}

# (def applyf (f args a s r m)
#   (if (= f apply)    (applyf (car args) (reduce join (cdr args)) a s r m)
#       (caris f 'lit) (if (proper f)
#                          (applylit f args a s r m)
#                          (sigerr 'bad-lit s r m))
#                      (sigerr 'cannot-apply s r m)))
sub _applyf {
    my ($f, $args, $a, $s, $r, $m) = @_;

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
            my ($s, $r, $m) = @_;

            my $apply_args = pop(@$r);
            _applyf($apply_op, $apply_args, $a, $s, $r, $m);
        };

        push @$s, $fu, $reduce_expr;
    }
    else {
        my $car_f = pair_car($f);
        if (!is_symbol($car_f) || symbol_name($car_f) ne "lit") {
            die "'cannot-apply\n";
        }
        # XXX: skipping `proper` check for now
        _applylit($f, $args, $a, $s, $r, $m);
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
sub _applylit {
    my ($f, $args, $a, $s, $r, $m) = @_;

    # XXX: skipping `inwhere`/`locfns` for now
    my $tag = pair_car(pair_cdr($f));
    my $tag_name = symbol_name($tag);
    my $rest = pair_cdr(pair_cdr($f));
    if ($tag_name eq "prim") {
        _applyprim(pair_car($rest), $args, $s, $r, $m);
    }
    elsif ($tag_name eq "clo") {
        my $env = pair_car($rest);
        my $parms = pair_car(pair_cdr($rest));
        my $body = pair_car(pair_cdr(pair_cdr($rest)));

        # XXX: skipping `okenv` and `okparms` checks for now
        _applyclo($parms, $args, $env, $body, $s, $r, $m);
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
sub _applyprim {
    my ($f, $args, $s, $r, $m) = @_;

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
    push @$r, $v;
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
sub _applyclo {
    my ($parms, $args, $env, $body, $s, $r, $m) = @_;

    my $fu1 = sub {
        my ($s, $r, $m) = @_;

        _pass($parms, $args, $env, $s, $r, $m);
    };
    my $fu2 = sub {
        my ($s, $r, $m) = @_;

        my $car_r = pop @$r;
        push @$s, [
            $body,
            $car_r,
        ];
    };
    push @$s, $fu2, $fu1;
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
sub _pass {
    my ($pat, $arg, $env, $s, $r, $m) = @_;

    if (is_symbol($pat) && symbol_name($pat) eq "nil") {
        # XXX: skipping the `'overargs` case for now
        push @$r, $env;
    }
    # XXX: skipping the literal case for now
    elsif (_variable($pat)) {
        push @$r, make_pair(make_pair($pat, $arg), $env);
    }
    # XXX: skipping the `t` case for now
    # XXX: skipping the `o` case for now
    else {
        _destructure($pat, $arg, $env, $s, $r, $m);
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
sub _destructure {
    my ($ps, $arg, $env, $s, $r, $m) = @_;
    my $p = pair_car($ps);
    $ps = pair_cdr($ps);

    if (is_symbol($arg) && symbol_name($arg) eq "nil") {
        # XXX: skipping the `(caris p o)` case for now
        die "'underargs\n";
    }
    # XXX: skipping the `(atom arg)` case for now
    else {
        my $fu1 = sub {
            my ($s, $r, $m) = @_;

            _pass($p, pair_car($arg), $env, $s, $r, $m);
        };
        my $fu2 = sub {
            my ($s, $r, $m) = @_;

            my $env = pop @$r;
            _pass($ps, pair_cdr($arg), $env, $s, $r, $m);
        };
        push @$s, $fu2, $fu1;
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
