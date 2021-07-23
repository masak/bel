package Language::Bel::Compiler::Pass::Flatten;
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
use Language::Bel::Reader qw(
    read_whole
);
use Language::Bel::Compiler::Gensym qw(
    gensym
    is_gensym
);
use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);

my %arg_count_of = (
    "id" => 2,
    "type" => 1,
);

sub new {
    my ($class) = @_;

    return $class->SUPER::new("flatten");
}

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
    my $a0_gensym = handle_expression($args[0], $instructions_ref);
    my $target_gensym = gensym();
    if ($name eq "id") {
        my $symbol;
        if (is_nil($args[1])) {
            $symbol = "nil";
        }
        elsif (is_pair($args[1])
            && is_symbol_of_name(car($args[1]), "quote")) {
            my $quote_cadr = car(cdr($args[1]));
            die "The quoted thing is not a symbol: ", _print($args[1])
                unless is_symbol($quote_cadr);
            $symbol = symbol_name($quote_cadr);
        }
        else {
            die "Unexpected not-a-symbol";
        }

        push @{$instructions_ref},
            read_whole("($target_gensym := (prim!id $a0_gensym '$symbol))");
    }
    elsif ($name eq "type") {
        push @{$instructions_ref},
            read_whole("($target_gensym := (prim!type $a0_gensym))");
    }
    else {
        die "Unexpected primitive `$name`";
    }
    return $target_gensym;
}

sub handle_expression {
    my ($expr, $instructions_ref) = @_;

    if (is_symbol($expr)) {
        return symbol_name($expr);
    }

    my $op = car($expr);
    my $args = cdr($expr);
    my @args;
    while (!is_nil($args)) {
        push @args, car($args);
        $args = cdr($args);
    }

    my $target_gensym;
    if (is_primitive($op)) {
        $target_gensym = handle_primitive($op, $instructions_ref, @args);
    }
    elsif (is_symbol_of_name($op, "no")) {
        if (scalar(@args) != 1) {
            die "expected 1 arg: ", _print($expr);
        }
        $target_gensym = gensym();
        my $a0_gensym = handle_expression($args[0], $instructions_ref);
        push @{$instructions_ref},
            read_whole("($target_gensym := (prim!id $a0_gensym 'nil))");
    }
    else {
        die "unexpected: ", _print($expr);
    }

    return $target_gensym;
}

sub listify {
    my (@elems) = @_;

    my $list = SYMBOL_NIL;
    for my $elem (reverse(@elems)) {
        $list = make_pair($elem, $list);
    }

    return $list;
}

# @override
sub check_precondition {
    my ($self, $ast) = @_;

    my $body = cdr(cdr(cdr($ast)));

    while (!is_nil($body)) {
        my $statement = car($body);
        die "Can't handle 'if' statements just yet"
            if is_pair($statement) && is_symbol_of_name(car($statement), "if");
        $body = cdr($body);
    }
}

# @override
sub do_translate {
    my ($self, $ast) = @_;

    $ast = cdr($ast);
    # skipping $fn_name

    $ast = cdr($ast);
    my $args = car($ast);

    my $body = cdr($ast);

    my @instructions;
    my $final_target_gensym = "<not set>";
    while (!is_nil($body)) {
        my $statement = car($body);
        $final_target_gensym = handle_expression($statement, \@instructions);
        $body = cdr($body);
    }

    if ($final_target_gensym eq "<not set>") {
        my $target_gensym = gensym();
        push @instructions, read_whole("($target_gensym := 'nil)");
        $final_target_gensym = $target_gensym;
    }

    push @instructions, read_whole("(return $final_target_gensym)");

    return make_pair(
        make_symbol("def-02"),
        make_pair(
            $args,
            listify(@instructions),
        ),
    );
}

# @override
sub check_postcondition {
    my ($self, $ast) = @_;

    my $body = cdr(cdr($ast));

    while (!is_nil($body)) {
        die "body not a pair"
            unless is_pair($body);

        my $operation = car($body);

        my @operands;
        while (!is_nil($operation)) {
            die "operation is not a pair"
                unless is_pair($operation);
            push @operands, car($operation);
            $operation = cdr($operation);
        }

        my $op_name = shift(@operands);

        if (is_symbol_of_name($op_name, "return")) {
            die "expected gensym as only operand to 'return'"
                unless scalar(@operands) == 1 && is_gensym($operands[0]);
        }
        elsif (is_gensym($op_name)) {
            die "expected two operands"
                unless scalar(@operands) == 2;
            die "expected := immediately after gensym"
                unless is_pair($operands[0])
                    && is_symbol_of_name(car($operands[0]), "compose")
                    && is_symbol_of_name(car(cdr($operands[0])), "=");

            my $rhs = $operands[1];
            my @rhs_operands;
            while (!is_nil($rhs)) {
                die "rhs operation is not a pair"
                    unless is_pair($rhs);
                push @rhs_operands, car($rhs);
                $rhs = cdr($rhs);
            }

            my $rhs_op = shift(@rhs_operands);

            if (is_pair($rhs_op)
                && is_symbol_of_name(car($rhs_op), "prim")
                && is_pair(car(cdr($rhs_op)))
                && is_symbol_of_name(car(car(cdr($rhs_op))), "quote")
                && is_symbol(car(cdr(car(cdr($rhs_op)))))) {

                my $primop_name = symbol_name(car(cdr(car(cdr($rhs_op)))));

                die "expected primop to be id or type"
                    unless $primop_name eq "id" || $primop_name eq "type";

                if ($primop_name eq "id") {
                    die "expected prim!id to have 2 operands"
                        unless scalar(@rhs_operands) == 2;

                    die "expected first prim!id operand to be a gensym"
                        unless is_gensym($rhs_operands[0]);

                    die "expected second prim!id operand to be a quoted symbol"
                        unless is_pair($rhs_operands[1])
                            && is_symbol_of_name(car($rhs_operands[1]), "quote")
                            && is_symbol(car(cdr($rhs_operands[1])));
                }
                elsif ($primop_name eq "type") {
                    die "expected prim!type to have 1 operand"
                        unless scalar(@rhs_operands) == 1;

                    die "expected prim!type operand to be a gensym"
                        unless is_gensym($rhs_operands[0]);
                }
                else {
                    die "unexpected type of primop: $primop_name";
                }
            }
            elsif (is_symbol_of_name($rhs_op, "quote")) {
                die "expected quote to have 1 operand"
                    unless scalar(@rhs_operands) == 1;

                die "expected quote operand to be a symbol"
                    unless is_symbol($rhs_operands[0]);
            }
            else {
                die "unexpected rhs";
            }
        }
        else {
            die "unrecognized operation: ", _print(car($body));
        }

        $body = cdr($body);
    }
}

1;
