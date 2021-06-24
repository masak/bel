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
    is_symbol
    is_symbol_of_name
    make_pair
    make_symbol
    symbol_name
    SYMBOL_NIL
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
            my ($message_str) = @_;

            die "Error during compilation: $message_str\n";
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

my %arg_count_of = (
    "id" => 2,
    "type" => 1,
);

sub is_primitive {
    my ($op) = @_;

    return
        unless is_symbol($op);
    my $name = symbol_name($op);
    return !!$arg_count_of{$name};
}

sub handle_primitive {
    my ($op, $instructions_ref, @args) = @_;

    my $name = symbol_name($op);
    my $expected_arg_count = $arg_count_of{$name};
    my $actual_arg_count = scalar(@args);
    die "Expected $expected_arg_count for primitive `$name`, "
        . "got $actual_arg_count"
        unless $actual_arg_count == $expected_arg_count;
    handle_expression($args[0], $instructions_ref);
    if ($name eq "id") {
        my $symbol;
        if (is_nil($args[1])) {
            $symbol = SYMBOL("nil");
        }
        elsif (is_pair($args[1])
            && is_symbol_of_name(car($args[1]), "quote")) {
            my $quote_cadr = car(cdr($args[1]));
            die "The quoted thing is not a symbol: ", _print($args[1])
                unless is_symbol($quote_cadr);
            my $symbol_name = symbol_name($quote_cadr);
            $symbol = SYMBOL($symbol_name);
        }
        else {
            die "Unexpected not-a-symbol";
        }

        push @{$instructions_ref}, (
            SET_PRIM_ID_REG_SYM, 0, 0, $symbol,
        );
    }
    elsif ($name eq "type") {
        push @{$instructions_ref}, (
            SET_PRIM_TYPE_REG, 0, 0, n,
        );
    }
    else {
        die "Unexpected primitive `$name`";
    }
}

sub handle_expression {
    my ($expr, $instructions_ref) = @_;

    return
        unless is_pair($expr);

    my $op = car($expr);
    my $args = cdr($expr);
    my @args;
    while (!is_nil($args)) {
        push @args, car($args);
        $args = cdr($args);
    }

    if (is_primitive($op)) {
        handle_primitive($op, $instructions_ref, @args);
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
    else {
        die "unexpected: ", _print($expr);
    }
}

my $unique_gensym_index = 0;

sub gensym {
    return make_symbol("gensym_" . sprintf("%04d", ++$unique_gensym_index));
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

    my $gensym = gensym();

    my $body = cdr($ast);
    my %translation = (
        $single_param_name => $gensym,
    );

    return make_pair(
        make_symbol("def"),
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

sub compile {
    my ($source) = @_;

    my $ast = read_whole($source);

    die _print(nanopass_01_alpha($ast));

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
