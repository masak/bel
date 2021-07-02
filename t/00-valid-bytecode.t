#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Bytecode qw(
    PARAM_IN
    PARAM_LAST
    PARAM_NEXT
    PARAM_OUT
    RETURN_REG
    SET_PARAM_NEXT
    SET_PRIM_ID_REG_SYM
    SET_PRIM_TYPE_REG
    SYM_NIL
    SYM_T
    SYM_PAIR
);
use Language::Bel::Globals::ByteFuncs qw(
    bytefunc
    all_bytefuncs
);

sub four_groups {
    my ($array) = @_;

    die "Length not divisible by 4"
        unless scalar(@$array) % 4 == 0;

    my @result;

    my $index = 0;
    while ($index < scalar(@$array)) {
        push @result, [@$array[$index .. $index + 3]];
        $index += 4;
    }

    return @result;
}

sub ops {
    my ($bytefunc) = @_;

    my $bytes = $bytefunc->bytes();
    return four_groups($bytes);
}

sub in {
    my ($element, @set) = @_;

    return grep { $_ == $element } @set;
}

sub tests_per_bytefunc { 4 }

sub registers_of {
    my ($op) = @_;
    my ($opcode, $operand1, $operand2, $operand3) = @$op;

    if (in($opcode, PARAM_IN, PARAM_LAST, PARAM_OUT)) {
        return ();
    }
    elsif (in($opcode, RETURN_REG, SET_PARAM_NEXT)) {
        return ($operand1);
    }
    elsif (in($opcode, SET_PRIM_TYPE_REG)) {
        return ($operand2, $operand1);
    }
    elsif (in($opcode, SET_PRIM_ID_REG_SYM)) {
        return ($operand2, $operand1);
    }
    else {
        die "Unknown opcode ", $opcode;
    }
}

sub max {
    my ($x, $y) = @_;

    return $x > $y ? $x : $y;
}

my @PARAM_OPCODES = (
    PARAM_IN,
    PARAM_LAST,
    PARAM_NEXT,
    PARAM_OUT,
    SET_PARAM_NEXT,
);

my @RETURN_OPCODES = (
    RETURN_REG,
);

my @bytefuncs = all_bytefuncs();

plan tests => scalar(@bytefuncs) * tests_per_bytefunc();

for my $name (@bytefuncs) {
    my $bytefunc = bytefunc($name);

    my $seen_non_param_op = 0;
    my $param_op_after_non_param_op = 0;

    my $max_register_index = -1;
    my $register_count = $bytefunc->reg_count();

    my $next_register_expected = 0;
    my $registers_introduced_in_sequence = 1;

    my $last_instruction_is_return = 0;

    for my $op (ops($bytefunc)) {
        my ($opcode, $operand1, $operand2, $operand3) = @$op;

        if (!in($opcode, @PARAM_OPCODES)) {
            $seen_non_param_op = 1;
        }

        if ($seen_non_param_op && in($opcode, @PARAM_OPCODES)) {
            $param_op_after_non_param_op = 1;
        }

        for my $register (registers_of($op)) {
            $max_register_index = max($register, $max_register_index);

            if ($register == $next_register_expected) {
                $next_register_expected += 1;
            }
            elsif ($register > $next_register_expected) {
                $registers_introduced_in_sequence = 0;
            }
        }

        $last_instruction_is_return = in($opcode, @RETURN_OPCODES);
    }

    ok !$param_op_after_non_param_op,
        "$name - no param-handling op after non-param-handling op";

    is $max_register_index + 1, $register_count,
        "$name - the register index is always one below the register count";

    ok $registers_introduced_in_sequence,
        "$name - registers are introduced in sequence 0..*";

    ok $last_instruction_is_return,
        "$name - the last instruction is RETURN";
}

