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

{
    # XXX: I just discovered that all the source files are stored as
    # DOS-newline format. I might decide to do something about this in
    # the future; Unix/Linux style format seems more appropriate.
    local $/ = "\r\n\r\n";  # paragraph mode
    while (<Language::Bel::Globals::DATA>) {
        s/(\r\n){1,2}$//;
        /^\(set (\w+)\s+(.+)\)$/ms
            or die "Unrecognized: $_";

        my $name = $1;
        my $value = $2;
        add_global($name, _read($value));
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
(set no (lit clo nil (x) (id x nil)))

(set atom (lit clo nil (x) (no (id (type x) 'pair))))

(set all
     (lit clo nil (f xs)
       (if (no xs)      t
           (f (car xs)) (all f (cdr xs))
                        nil)))

(set some
     (lit clo nil (f xs)
       (if (no xs)      nil
           (f (car xs)) xs
                        (some f (cdr xs)))))

(set reduce
     (lit clo nil (f xs)
       (if (no (cdr xs))
           (car xs)
           (f (car xs) (reduce f (cdr xs))))))

(set cons
     (lit clo nil args
       (reduce join args)))

(set append
     (lit clo nil args
       (if (no (cdr args)) (car args)
           (no (car args)) (apply append (cdr args))
                           (cons (car (car args))
                                 (apply append (cdr (car args))
                                               (cdr args))))))

(set snoc
     (lit clo nil args
       (append (car args) (cdr args))))

(set list
     (lit clo nil args
       (append args nil)))

(set map
     (lit clo nil (f . ls)
       (if (no ls)       nil
           (some no ls)  nil
           (no (cdr ls)) (cons (f (car (car ls)))
                               (map f (cdr (car ls))))
                         (cons (apply f (map car ls))
                               (apply map f (map cdr ls))))))
