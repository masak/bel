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

add_global("snoc", _read("
    (lit clo nil args
      (append (car args) (cdr args)))
"));

add_global("list", _read("
    (lit clo nil args
      (append args nil))
"));

add_global("map", _read("
    (lit clo nil (f . ls)
      (if (no ls)       nil
          (some no ls)  nil
          (no (cdr ls)) (cons (f (car (car ls)))
                              (map f (cdr (car ls))))
                        (cons (apply f (map car ls))
                              (apply map f (map cdr ls)))))
"));

sub GLOBALS {
    return $GLOBALS;
}

our @EXPORT_OK = qw(
    GLOBALS
);

1;
