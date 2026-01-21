package Language::Bel::Compiler::Pass::Allocate;
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
);
use Language::Bel::Printer qw(
    _print
);
use Language::Bel::Compiler::Gensym qw(
    is_gensym
);
use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);

sub new {
    my ($class) = @_;

    return $class->SUPER::new("allocate-registers");
}

sub substitute_registers {
    my ($expr) = @_;

    if (is_symbol($expr) && is_gensym($expr)) {
        return make_symbol("%0");
    }
    elsif (is_pair($expr)) {
        return make_pair(
            substitute_registers(car($expr)),
            substitute_registers(cdr($expr)),
        );
    }
    else {
        return $expr;
    }
}

sub starts_with {
    my ($string, $prefix) = @_;

    return substr($string, 0, length($prefix)) eq $prefix;
}

my $REGISTER_PREFIX = "%";

sub is_register {
    my ($expr) = @_;

    return is_symbol($expr)
        && starts_with(symbol_name($expr), $REGISTER_PREFIX);
}

# @override
sub check_precondition {
    # no checks
}

# @override
sub do_translate {
    my ($self, $ast) = @_;

    $ast = cdr($ast);
    my $args = substitute_registers(car($ast));

    my $body = cdr($ast);

    return make_pair(
        make_symbol("def-03"),
        make_pair(
            $args,
            substitute_registers($body),
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
                unless scalar(@operands) == 1 && is_register($operands[0]);
        }
        elsif (is_register($op_name)) {
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

                    die "expected first prim!id operand to be a register"
                        unless is_register($rhs_operands[0]);

                    die "expected second prim!id operand to be a quoted symbol"
                        unless is_pair($rhs_operands[1])
                            && is_symbol_of_name(car($rhs_operands[1]), "quote")
                            && is_symbol(car(cdr($rhs_operands[1])));
                }
                elsif ($primop_name eq "type") {
                    die "expected prim!type to have 1 operand"
                        unless scalar(@rhs_operands) == 1;

                    die "expected prim!type operand to be a register"
                        unless is_register($rhs_operands[0]);
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
