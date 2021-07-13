package Language::Bel::Compiler::Pass01;

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    is_nil
    is_pair
    is_symbol
    make_pair
    make_symbol
    symbol_name
    SYMBOL_NIL
);
use Language::Bel::Printer qw(
    _print
);
use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);
use Language::Bel::Compiler::Gensym qw(
    gensym
);

use Exporter 'import';

sub replace_variables {
    my ($ast, $translation_ref) = @_;

    if (is_symbol($ast)) {
        my $name = symbol_name($ast);
        return $translation_ref->{$name} || $ast;
    }
    elsif (is_pair($ast)) {
        my $car = replace_variables(car($ast), $translation_ref);
        my $cdr = replace_variables(cdr($ast), $translation_ref);
        return make_pair($car, $cdr);
    }
    else {
        die "Unexpected type: ", _print($ast);
    }
}

sub nanopass_01_alpha {
    my ($ast) = @_;

    $ast = cdr($ast);
    my $fn_name = car($ast);

    $ast = cdr($ast);
    my $args = car($ast);

    die "Not general enough to handle these args yet: ", _print($args)
        unless is_pair($args)
            && is_symbol(car($args))
            && is_nil(cdr($args));

    my $single_param_name = symbol_name(car($args));

    my $gensym = make_symbol(gensym());

    my $body = cdr($ast);
    my %translation = (
        $single_param_name => $gensym,
    );

    return make_pair(
        make_symbol("def-01"),
        make_pair(
            $fn_name,
            make_pair(
                make_pair(
                    $gensym,
                    SYMBOL_NIL,
                ),
                replace_variables($body, \%translation),
            ),
        ),
    );
}

our @EXPORT_OK = qw(
    nanopass_01_alpha
);

1;
