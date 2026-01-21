package Language::Bel::Compiler::Pass::Alpha;
use base qw(Language::Bel::Compiler::Pass);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    is_nil
    is_pair
    is_symbol
    is_symbol_of_name
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
    is_gensym
);

sub new {
    my ($class) = @_;

    return $class->SUPER::new("alpha");
}

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

# @override
sub check_precondition {
    my ($self, $ast) = @_;

    my $args = car(cdr(cdr($ast)));

    die "Not general enough to handle these args yet: ", _print($args)
        unless is_pair($args)
            && is_symbol(car($args))
            && is_nil(cdr($args));
}

# @override
sub do_translate {
    my ($self, $ast) = @_;

    $ast = cdr($ast);
    my $fn_name = car($ast);

    $ast = cdr($ast);
    my $args = car($ast);

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

# @override
sub check_postcondition {
    my ($self, $ast) = @_;

    my $args = car(cdr(cdr($ast)));
    my $body = cdr(cdr(cdr($ast)));

    assure_meets_postcondition($body);
}

sub is_among_symbol_names {
    my ($value, @names) = @_;

    for my $name (@names) {
        return 1
            if is_symbol_of_name($value, $name);
    }
    return '';
}

sub assure_meets_postcondition {
    my ($value) = @_;

    if (is_nil($value)) {
        return;
    }
    elsif (is_pair($value) && is_symbol_of_name(car($value), "quote")) {
        return;
    }
    elsif (is_pair($value)) {
        assure_meets_postcondition(car($value));
        assure_meets_postcondition(cdr($value));
    }
    elsif (is_gensym($value)) {
        return;
    }
    elsif (is_among_symbol_names($value, "id", "type")) {
        return;
    }
    elsif (is_symbol_of_name($value, "no")) {
        return;         # XXX: should be generalized to "known globals"
    }
    else {
        die "Doesn't meet precondition: '", _print($value), "'";
    }
}

1;
