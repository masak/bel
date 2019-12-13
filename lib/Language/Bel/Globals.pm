package Language::Bel::Globals;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    make_pair
    make_symbol
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
);
use Language::Bel::Primitives qw(
    PRIMITIVES
);
use Language::Bel::Reader qw(
    _read
);

sub new {
    my ($class, $options_ref) = @_;
    my $self = {
        ref($options_ref) eq "HASH" ? %$options_ref : (),
    };

    my $g = defined($self->{g})
        ? $self->{g}
        : SYMBOL_NIL;
    $self->{g} = $g;

    return bless($self, $class);
}

sub interpreter {
    my ($self, $new_value) = @_;

    if (defined($new_value)) {
        $self->{interpreter} = $new_value;
    }

    return $self->{interpreter};
}

sub g {
    my ($self, $new_value) = @_;

    if (defined($new_value)) {
        $self->{g} = $new_value;
    }

    return $self->{g};
}

sub set {
    my ($self, $name, $value) = @_;

    $self->g(make_pair(
        make_pair(make_symbol($name), $value),
        $self->g(),
    ));
}

my @DECLARATIONS;
{
    # XXX: I'm running this on Windows, but I need to write a portable
    # solution that also considers Unix/Linux newlines.
    local $/ = "\r\n\r\n";  # paragraph mode
    while (<Language::Bel::Globals::DATA>) {
        s/(\r\n){1,2}$//;
        push @DECLARATIONS, $_;
    }
}

sub initialize {
    my ($self) = @_;

    for my $prim_name (qw(car cdr id join type)) {
        $self->set($prim_name, PRIMITIVES->{$prim_name});
    }

    for my $declaration (@DECLARATIONS) {
        my ($name, $value);

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
        if ($declaration =~ /^\(def (\w+) (\w+|\([^)]*\))\s+(.+)\)$/ms) {
            # (From bellanguage.txt)
            #
            # In the source I try not to use things before I've defined them,
            # but I've made a handful of exceptions to make the code easier
            # to read.
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
            $value = "(lit clo nil $p $e)";
        }
        elsif ($declaration =~ /^\(mac (\w+) (\w+|\([^)]*\))\s+(.+)\)$/ms) {
            # and when you see
            #
            # (mac n p e)
            #
            # treat it as an abbreviation for
            #
            # (set n (lit mac (lit clo nil p e)))

            $name = $1;
            my ($p, $e) = ($2, $3);
            $value = "(lit mac (lit clo nil $p $e))";
        }
        elsif ($declaration =~ /\(set (\w+) (.+)\)/ms) {
            ($name, $value) = ($1, $2);
        }
        else {
            die "Unrecognized: $declaration";
        }

        $self->set($name, $self->{interpreter}->eval_ast(_read($value)));
    }
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
    (cons 'list ''lit ''clo 'scope (list 'quote parms) (list 'quote (car body)) nil)
    (cons 'list ''lit ''clo 'scope (list 'quote parms) (list 'quote (cons 'do body)) nil)))

(set vmark (join))

(def uvar ()
  (list vmark))

(mac do args
  (reduce (fn (x y)
            (list (list 'fn (uvar) y) x))
          args))

(mac bquote (e)
  ((fn ((sub change))
     (if change sub (list 'quote e)))
   (bqex e)))

(def caris (x y)
  (if (no (atom x)) (id (car x) y)))

(def bqex (e)
  (if (no e)              (list nil nil)
      (atom e)            (list (list 'quote e) nil)
      (caris e 'comma)    (list (car (cdr e)) t)
      (caris e 'comma-at) (list (list 'splice (car (cdr e))) t)
                          (bqexpair e)))

(def bqexpair (e)
  ((fn ((a achange))
    ((fn ((d dchange))
      (if (if achange t dchange)
          (list (if (caris d 'splice)
                    (if (caris a 'splice)
                        (list 'apply 'append (car (cdr a)) (car (cdr d)))
                        (list 'apply 'cons a (car (cdr d))))
                    (caris a 'splice)
                    (list 'append (car (cdr a)) d)
                    (list 'cons a d))
                t)
          (list (list 'quote e) nil)))
     (bqex (cdr e))))
    (bqex (car e))))
