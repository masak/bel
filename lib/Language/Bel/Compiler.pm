package Language::Bel::Compiler;

use 5.006;
use strict;
use warnings;

use Language::Bel::Bytecode qw(
    n
    PARAM_IN
    PARAM_LAST
    PARAM_OUT
    RETURN_REG
    SET_PARAM_NEXT
    SET_PRIM_ID_REG_SYM
    SET_PRIM_TYPE_REG
    SYMBOL
);
use Language::Bel::Pair::ByteFunc qw(
    make_bytefunc
);
use Language::Bel::Core qw(
    is_nil
    is_pair
    is_symbol_of_name
);
use Language::Bel::Primitives;
use Language::Bel::Printer qw(
    _print
);
use Language::Bel::Reader qw(
    read_whole
);

use Exporter 'import';

{
    my $primitives = Language::Bel::Primitives->new({
        output => sub {},
        read_char => sub {},
        err => sub {
            die "Unexpected error during compilation";
        },
    });

    sub car {
        my ($pair) = @_;

        return $primitives->prim_car($pair);
    }

    sub cdr {
        my ($pair) = @_;

        return $primitives->prim_cdr($pair);
    }
}

sub handle_expression {
    my ($expr, $instructions_ref) = @_;

    my $op = car($expr);
    my $args = cdr($expr);
    my @args;
    while (!is_nil($args)) {
        push @args, car($args);
        $args = cdr($args);
    }

    if (is_symbol_of_name($op, "id")) {
        if (scalar(@args) == 2
            && is_symbol_of_name($args[0], "x")
            && is_nil($args[1])) {
            push @{$instructions_ref}, (
                SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("nil"),
            );
        }
        elsif (scalar(@args) == 2
            && is_pair($args[0])
            && is_pair($args[1])
            && is_symbol_of_name(car($args[1]), "quote")) {
            handle_expression($args[0], $instructions_ref);
            push @{$instructions_ref}, (
                SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("pair"),
            );
        }
        else {
            die "unexpected: ", _print($expr);
        }
    }
    elsif (is_symbol_of_name($op, "no")) {
        if (scalar(@args) != 1) {
            die "expected 1 arg: ", _print($expr);
        }
        handle_expression($args[0], $instructions_ref);
        push @{$instructions_ref}, (
            SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("nil"),
        );
    }
    elsif (is_symbol_of_name($op, "type")) {
        if (scalar(@args) != 1) {
            die "expected 1 arg: ", _print($expr);
        }
        push @{$instructions_ref}, (
            SET_PRIM_TYPE_REG, 0, 0, n,
        );
    }
    else {
        die "unexpected: ", _print($expr);
    }
}

sub compile {
    my ($source) = @_;

    my $ast = read_whole($source);

    my $def = car($ast);

    $ast = cdr($ast);
    my $fn_name = car($ast);

    $ast = cdr($ast);
    my $args = car($ast);

    my @param_handling = (
        PARAM_IN, n, n, n,
        SET_PARAM_NEXT, 0, n, n,
        PARAM_LAST, n, n, n,
        PARAM_OUT, n, n, n,
    );

    $ast = cdr($ast);

    my @instructions;
    while (!is_nil($ast)) {
        my $statement = car($ast);
        handle_expression($statement, \@instructions);
        $ast = cdr($ast);
    }

    return make_bytefunc(1, [
        @param_handling,
        @instructions,
        RETURN_REG, 0, n, n,
    ]);
}

our @EXPORT_OK = qw(
    compile
);

1;
