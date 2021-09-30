#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Bytecode qw(
    four_groups
    param_instruction
    registers_of
    return_or_jump
);
use Language::Bel::Globals::ByteFuncs qw(
    bytefunc
    all_bytefuncs
);

sub tests_per_bytefunc { 4 }

sub max {
    my ($x, $y) = @_;

    return $x > $y ? $x : $y;
}

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

    my $last_instruction_is_return_or_jmp = 0;

    for my $op (four_groups($bytefunc->bytes())) {
        my ($opcode, $operand1, $operand2, $operand3) = @$op;

        if (!param_instruction($opcode)) {
            $seen_non_param_op = 1;
        }

        if ($seen_non_param_op && param_instruction($opcode)) {
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

        $last_instruction_is_return_or_jmp = return_or_jump($opcode);
    }

    ok !$param_op_after_non_param_op,
        "$name - no param-handling op after non-param-handling op";

    is $max_register_index + 1, $register_count,
        "$name - max register index == register count - 1";

    ok $registers_introduced_in_sequence,
        "$name - registers are introduced in sequence 0..*";

    ok $last_instruction_is_return_or_jmp,
        "$name - the last instruction is RETURN or JMP";
}

