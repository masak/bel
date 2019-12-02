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
use Exporter 'import';

my $GLOBALS = SYMBOL_NIL;

sub set {
    my ($name, $value) = @_;

    $GLOBALS = make_pair(
        make_pair(make_symbol($name), $value),
        $GLOBALS,
    );
}

for my $prim_name (qw(car cdr id join type)) {
    set($prim_name, PRIMITIVES->{$prim_name});
}

{
    # XXX: I just discovered that all the source files are stored as
    # DOS-newline format. I might decide to do something about this in
    # the future; Unix/Linux style format seems more appropriate.
    local $/ = "\r\n\r\n";  # paragraph mode
    while (<Language::Bel::Globals::DATA>) {
        s/(\r\n){1,2}$//;
        # XXX: Just hunting for the next closing parenthesis, like this
        # regex does, it too simplistic for the general case. It'll work
        # for a while, but it'll fail once we get to `mem`:
        #
        #     (def mem (x ys (o f =))
        #       (some [f _ x] ys))
        #
        # A more general solution would involve the things Text::Balanced
        # and Regexp::Common::balanced do, but I haven't evaluated those
        # enough to choose one yet.
        #
        # Of course, we could also, do our own nested matcher using
        # (?P<NAME>pattern) and (?P>NAME) syntxes, but that's 5.10+ syntax.
        # Another option might be to capture everything and then do the
        # parenthesis counting in a separate tokenizing-like postprocessing
        # step.
        /^\(def (\w+) (\w+|\([^)]+\))\s+(.+)\)$/ms
            or die "Unrecognized: $_";

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

        my $n = $1;
        my $p = $2;
        my $e = $3;

        my $lit = "(lit clo nil $p $e)";
        set($n, _read($lit));
    }
}

sub GLOBALS {
    return $GLOBALS;
}

our @EXPORT_OK = qw(
    GLOBALS
);

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
