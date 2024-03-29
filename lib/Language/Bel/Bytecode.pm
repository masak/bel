package Language::Bel::Bytecode;

use 5.006;
use strict;
use warnings;

use Language::Bel::AsyncCall qw(
    make_async_call
);
use Language::Bel::Core qw(
    is_nil
    is_pair
    is_symbol
    make_pair
    make_symbol
    pair_car
    pair_cdr
    pair_set_car
    pair_set_cdr
    SYMBOL_NIL
    SYMBOL_T
    symbol_name
);
use Exporter 'import';

sub PARAMS { 0x00 }
sub SET_PARAMS { 0x01 }

sub PRIM_XAR { 0x10 }
sub PRIM_XDR { 0x11 }
sub PRIM_CAR { 0x12 }
sub PRIM_CDR { 0x13 }
sub PRIM_ID_REG_SYM { 0x14 }
sub PRIM_JOIN_NIL_NIL { 0x15 }
sub PRIM_JOIN_REG_NIL { 0x16 }
sub PRIM_JOIN_REG_REG { 0x17 }
sub PRIM_TYPE_REG { 0x18 }

sub SET_PRIM_CAR { 0x22 }
sub SET_PRIM_CDR { 0x23 }
sub SET_PRIM_ID_REG_SYM { 0x24 }
sub SET_PRIM_JOIN_NIL_NIL { 0x25 }
sub SET_PRIM_JOIN_REG_NIL { 0x26 }
sub SET_PRIM_JOIN_REG_REG { 0x27 }
sub SET_PRIM_TYPE_REG { 0x28 }

sub SET_REG { 0x30 }
sub SET_SYM { 0x31 }

sub JMP { 0x40 }
sub IF_JMP { 0x41 }
sub UNLESS_JMP { 0x42 }

sub ARG_IN { 0x50 }
sub ARG_NEXT { 0x51 }
sub ARG_OUT { 0x52 }

sub APPLY { 0x60 }

sub SET_APPLY { 0x70 }

sub ERR_IF { 0xE0 }

sub RETURN_REG { 0xF0 }
sub RETURN_IF { 0xF1 }
sub RETURN_NIL_UNLESS { 0xF2 }
sub RETURN_T_UNLESS { 0xF3 }

my @registered_symbols = (
    "nil",
    "t",
    "pair",
    "symbol",
    "char",
    "stream",
    "overargs",
);

my @SYMBOLS = map { make_symbol($_) } @registered_symbols;

my %index_of;
my $index = 0;
for my $name (@registered_symbols) {
    $index_of{$name} = $index;
    ++$index;
}

sub SYMBOL {
    my ($name) = @_;

    die "Unknown symbol `$name`"
        unless defined $index_of{$name};

    return $index_of{$name};
}

sub in {
    my ($element, @set) = @_;

    return grep { $_ == $element } @set;
}

sub param_instruction {
    my ($opcode) = @_;

    return $opcode == SET_PARAMS;
}

my @RETURN_OR_JMP = (
    JMP,
    RETURN_REG,
);

sub return_or_jump {
    my ($opcode) = @_;

    return in($opcode, @RETURN_OR_JMP);
}

sub operand_is_register {
    my ($operand) = @_;

    return $operand =~ /^\d+$/;
}

sub operand_is_instruction_pointer {
    my ($operand) = @_;

    return $operand =~ /^\d+$/
        && $operand / 4 == int($operand / 4);
}

sub operand_is_symbol {
    my ($operand) = @_;

    return $operand !~ /^\d+$/
        && defined $index_of{$operand};
}

sub if_jmp {
    die "`if_jmp` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register, $target_ip) = @_;

    die "Illegal register argument to `if_jmp`"
        unless operand_is_register($register);
    die "Illegal instruction pointer argument to `if_jmp`"
        unless operand_is_instruction_pointer($target_ip);

    return (IF_JMP, $register, $target_ip, 0);
}

sub unless_jmp {
    die "`unless_jmp` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register, $target_ip) = @_;

    die "Illegal register argument to `unless_jmp`"
        unless operand_is_register($register);
    die "Illegal instruction pointer argument to `unless_jmp`"
        unless operand_is_instruction_pointer($target_ip);

    return (UNLESS_JMP, $register, $target_ip, 0);
}

sub jmp {
    die "`jmp` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($target_ip) = @_;

    die "Illegal instruction pointer argument to `jmp`"
        unless operand_is_instruction_pointer($target_ip);

    return (JMP, $target_ip, 0, 0);
}

sub arg_in {
    die "`arg_in` instruction expects no operands"
        unless @_ == 0;

    return (ARG_IN, 0, 0, 0);
}

sub arg_next {
    die "`arg_next` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    return (ARG_NEXT, $register, 0, 0);
}

sub arg_out {
    die "`arg_out` instruction expects no operands"
        unless @_ == 0;

    return (ARG_OUT, 0, 0, 0);
}

sub apply {
    die "`apply` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    return (APPLY, $register, 0, 0);
}

sub params {
    die "`params` instruction expects no operands"
        unless @_ == 0;

    return (PARAMS, 0, 0, 0);
}

sub prim_car {
    die "`prim_car` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `prim_car`"
        unless operand_is_register($register);

    return (PRIM_CAR, $register, 0, 0);
}

sub prim_cdr {
    die "`prim_cdr` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `prim_cdr`"
        unless operand_is_register($register);

    return (PRIM_CDR, $register, 0, 0);
}

sub prim_id_reg_sym {
    die "`prim_id_reg_sym` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register, $symbol) = @_;

    die "Illegal register argument to `prim_id_reg_sym`"
        unless operand_is_register($register);
    die "Illegal symbol argument to `prim_id_reg_sym`"
        unless operand_is_symbol($symbol);

    return (PRIM_ID_REG_SYM, $register, SYMBOL($symbol), 0);
}

sub prim_join_nil_nil {
    die "`prim_join_nil_nil` instruction expects exactly 0 operands"
        unless @_ == 0;

    return (PRIM_JOIN_NIL_NIL, SYMBOL("nil"), SYMBOL("nil"), 0);
}

sub prim_join_reg_nil {
    die "`prim_join_reg_nil` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `prim_join_reg_sym`"
        unless operand_is_register($register);

    return (PRIM_JOIN_REG_NIL, $register, SYMBOL("nil"), 0);
}

sub prim_join_reg_reg {
    die "`prim_join_reg_reg` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register1, $register2) = @_;

    die "Illegal first register argument to `prim_id_reg_reg`"
        unless operand_is_register($register1);
    die "Illegal second register argument to `prim_id_reg_reg`"
        unless operand_is_register($register2);

    return (PRIM_JOIN_REG_REG, $register1, $register2, 0);
}

sub prim_type_reg {
    die "`prim_type_reg` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `prim_type_reg`"
        unless operand_is_register($register);

    return (PRIM_TYPE_REG, $register, 0, 0);
}

sub prim_xar {
    die "`prim_xar` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register1, $register2) = @_;

    die "Illegal first register argument to `prim_xar`"
        unless operand_is_register($register1);
    die "Illegal second register argument to `prim_xar`"
        unless operand_is_register($register2);

    return (PRIM_XAR, $register1, $register2, 0);
}

sub prim_xdr {
    die "`prim_xdr` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register1, $register2) = @_;

    die "Illegal first register argument to `prim_xdr`"
        unless operand_is_register($register1);
    die "Illegal second register argument to `prim_xdr`"
        unless operand_is_register($register2);

    return (PRIM_XDR, $register1, $register2, 0);
}

sub err_if {
    die "`err_if` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register, $symbol) = @_;

    die "Illegal register argument to `err_if`"
        unless operand_is_register($register);

    die "Illegal symbol name argument to `err_if`"
        unless operand_is_symbol($symbol);

    return (ERR_IF, $register, SYMBOL($symbol), 0);
}

sub return_if {
    die "`return_if` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `return_if`"
        unless operand_is_register($register);

    return (RETURN_IF, $register, 0, 0);
}

sub return_reg {
    die "`return_reg` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `return_reg`"
        unless operand_is_register($register);

    return (RETURN_REG, $register, 0, 0);
}

sub return_nil_unless {
    die "`return_nil_unless` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `return_nil_unless`"
        unless operand_is_register($register);

    return (RETURN_NIL_UNLESS, $register, 0, 0);
}

sub return_t_unless {
    die "`return_t_unless` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `return_t_unless`"
        unless operand_is_register($register);

    return (RETURN_T_UNLESS, $register, 0, 0);
}

sub set {
    die "`set` instruction expects exactly 2 or 5 operands"
        unless @_ == 2 || @_ == 5;

    if (@_ == 2) {
        my ($register1, $operand2) = @_;

        die "Illegal first register argument to `set`"
            unless operand_is_register($register1);

        if (operand_is_symbol($operand2)) {
            return (SET_SYM, $register1, SYMBOL($operand2), 0);
        }
        elsif (operand_is_register($operand2)) {
            return (SET_REG, $register1, $operand2, 0);
        }
        else {
            die "Illegal second register argument to `set`: ", $operand2;
        }
    }
    else {  # @_ == 5
        my ($register, $op, $r1, $r2, $r3) = @_;

        die "The third operand must always be 0 when wrappipng in `set`"
            unless $r3 == 0;

        my $set_op = $op == APPLY ? SET_APPLY
            : $op == PARAMS ? SET_PARAMS
            : $op == PRIM_CAR ? SET_PRIM_CAR
            : $op == PRIM_CDR ? SET_PRIM_CDR
            : $op == PRIM_ID_REG_SYM ? SET_PRIM_ID_REG_SYM
            : $op == PRIM_TYPE_REG ? SET_PRIM_TYPE_REG
            : $op == PRIM_JOIN_NIL_NIL ? SET_PRIM_JOIN_NIL_NIL
            : $op == PRIM_JOIN_REG_NIL ? SET_PRIM_JOIN_REG_NIL
            : $op == PRIM_JOIN_REG_REG ? SET_PRIM_JOIN_REG_REG
            : die sprintf("Unexpected underlying op to `set`: 0x%02x", $op);

        return ($set_op, $register, $r1, $r2);
    }
}

sub has_0_operands {
    my ($opcode) = @_;

    return in($opcode,
        PARAMS, JMP, ARG_IN, ARG_OUT, APPLY
    );
}

sub has_1_operand {
    my ($opcode) = @_;

    return in($opcode,
        RETURN_IF, RETURN_REG, SET_PARAMS, SET_PRIM_JOIN_NIL_NIL, IF_JMP,
        UNLESS_JMP, ARG_NEXT, ERR_IF, RETURN_NIL_UNLESS, RETURN_T_UNLESS,
        SET_APPLY, SET_SYM
    );
}

sub has_2_operands {
    my ($opcode) = @_;

    return in($opcode,
        PRIM_XAR, PRIM_XDR, SET_PRIM_TYPE_REG, SET_PRIM_ID_REG_SYM,
        SET_PRIM_JOIN_REG_NIL, SET_REG, SET_PRIM_CAR, SET_PRIM_CDR
    );
}

sub has_3_operands {
    my ($opcode) = @_;

    return in($opcode, SET_PRIM_JOIN_REG_REG);
}

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

sub registers_of {
    my ($op) = @_;
    my ($opcode, $operand1, $operand2, $operand3) = @$op;

    if (has_0_operands($opcode)) {
        return ();
    }
    elsif (has_1_operand($opcode)) {
        return ($operand1);
    }
    elsif (has_2_operands($opcode)) {
        return ($operand2, $operand1);
    }
    elsif (has_3_operands($opcode)) {
        return ($operand2, $operand3, $operand1);
    }
    else {
        die sprintf("Unknown opcode 0x%x", $opcode);
    }
}

sub belify_bytefunc {
    my ($bytefunc) = @_;

    my @ops = four_groups($bytefunc->bytes());
    my @instructions = map { belify_instruction($_) } @ops;
    my $instructions = join "", map { "\n  $_" } @instructions;

    return "(bytefunc$instructions)\n";
}

sub belify_instruction {
    my ($op) = @_;
    my ($opcode, $o1, $o2, $o3) = @$op;

    if ($opcode == SET_PARAMS) {
        my $target = "%$o1";
        return "($target := params)";
    }
    elsif ($opcode == SET_PRIM_CAR) {
        my $target = "%$o1";
        my $reg = "%$o2";
        return "($target := prim!car $reg)";
    }
    elsif ($opcode == SET_PRIM_CDR) {
        my $target = "%$o1";
        my $reg = "%$o2";
        return "($target := prim!cdr $reg)";
    }
    elsif ($opcode == SET_PRIM_ID_REG_SYM) {
        my $target = "%$o1";
        my $reg = "%$o2";
        my $sym = symbol_of($o3);
        return "($target := prim!id $reg '$sym)";
    }
    elsif ($opcode == SET_PRIM_TYPE_REG) {
        my $target = "%$o1";
        my $reg = "%$o2";
        return "($target := prim!type $reg)";
    }
    elsif ($opcode == SET_SYM) {
        my $target = "%$o1";
        my $sym = symbol_of($o2);
        return "($target := '$sym)";
    }
    elsif ($opcode == ERR_IF) {
        my $reg = "%$o1";
        my $sym = symbol_of($o2);
        return "(err!if $reg '$sym)";
    }
    elsif ($opcode == RETURN_REG) {
        my $reg = "%$o1";
        return "(return $reg)";
    }
    else {
        die sprintf("Unknown opcode 0x%02x", $opcode);
    }
}

sub symbol_of {
    my ($index) = @_;
    if ($index < 0 || scalar(@registered_symbols) < $index) {
        die "Symbol index `$index` out of bounds";
    }
    return $registered_symbols[$index];
}

# unique symbol
my $RESUMING_AT = {};

sub run_bytefunc {
    my ($bytecode, $reg_count, $bel, @args) = @_;

    my $ip;
    my @registers;
    if (@args && $args[0] == $RESUMING_AT) {
        $ip = $args[1];
        @registers = @{ $args[2] };
        my $target_register_no = $args[3];
        my $result = $args[4];
        $registers[ $target_register_no ] = $result;
    }
    else {
        $ip = 0;
        @registers = (SYMBOL_NIL) x $reg_count;
    }

    my @args_to_call;

    while (1) {
        my $opcode = $bytecode->[$ip];
        if ($opcode == SET_PARAMS) {
            my $args = SYMBOL_NIL;
            for my $arg (reverse(@args)) {
                $args = make_pair($arg, $args);
            }

            my $reg_no = $bytecode->[$ip + 1];
            $registers[$reg_no] = $args;
        }
        elsif ($opcode == JMP) {
            my $branch_address = $bytecode->[$ip + 1];
            $ip = $branch_address;
            next;
        }
        elsif ($opcode == IF_JMP) {
            my $register_no = $bytecode->[$ip + 1];
            my $branch_address = $bytecode->[$ip + 2];
            my $value = $registers[$register_no];
            if (!is_nil($value)) {
                $ip = $branch_address;
                next;
            }
        }
        elsif ($opcode == UNLESS_JMP) {
            my $register_no = $bytecode->[$ip + 1];
            my $branch_address = $bytecode->[$ip + 2];
            my $value = $registers[$register_no];
            if (is_nil($value)) {
                $ip = $branch_address;
                next;
            }
        }
        elsif ($opcode == ARG_IN) {
            # do nothing for now
        }
        elsif ($opcode == ARG_NEXT) {
            my $register_no = $bytecode->[$ip + 1];
            push @args_to_call, $registers[$register_no];
        }
        elsif ($opcode == ARG_OUT) {
            # do nothing for now
        }
        elsif ($opcode == SET_APPLY) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $fn_register_no = $bytecode->[$ip + 2];
            return make_async_call(
                $registers[$fn_register_no],
                [@args_to_call],
                sub {
                    my ($result) = @_;
                    return run_bytefunc(
                        $bytecode,
                        $reg_count,
                        $bel,
                        $RESUMING_AT,
                        $ip + 4,
                        \@registers,
                        $target_register_no,
                        $result,
                    );
                },
            );
        }
        elsif ($opcode == SET_PRIM_CAR) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $register_no = $bytecode->[$ip + 2];
            my $object = $registers[$register_no];
            $registers[$target_register_no] = is_nil($object)
                ? SYMBOL_NIL
                : !is_pair($object)
                    ? die "`car` on atom\n"
                    : pair_car($object);
        }
        elsif ($opcode == SET_PRIM_CDR) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $register_no = $bytecode->[$ip + 2];
            my $object = $registers[$register_no];
            $registers[$target_register_no] = is_nil($object)
                ? SYMBOL_NIL
                : !is_pair($object)
                    ? die "`cdr` on atom\n"
                    : pair_cdr($object);
        }
        elsif ($opcode == PRIM_XAR) {
            my $register_no = $bytecode->[$ip + 1];
            my $new_car_register_no = $bytecode->[$ip + 2];
            my $object = $registers[$register_no];
            my $new_car = $registers[$new_car_register_no];
            if (!is_pair($object)) {
                die "`xar` on atom\n";
            }
            pair_set_car($object, $new_car);
        }
        elsif ($opcode == PRIM_XDR) {
            my $register_no = $bytecode->[$ip + 1];
            my $new_cdr_register_no = $bytecode->[$ip + 2];
            my $object = $registers[$register_no];
            my $new_cdr = $registers[$new_cdr_register_no];
            if (!is_pair($object)) {
                die "`xdr` on atom\n";
            }
            pair_set_cdr($object, $new_cdr);
        }
        elsif ($opcode == SET_PRIM_ID_REG_SYM) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $register_no = $bytecode->[$ip + 2];
            my $value = $registers[$register_no];
            my $symbol_id = $bytecode->[$ip + 3];
            my $symbol = $SYMBOLS[$symbol_id];
            $registers[$target_register_no]
                = is_symbol($value)
                    && symbol_name($value) eq symbol_name($symbol)
                    ? SYMBOL_T
                    : SYMBOL_NIL;
        }
        elsif ($opcode == SET_PRIM_JOIN_REG_REG) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $car_register_no = $bytecode->[$ip + 2];
            my $cdr_register_no = $bytecode->[$ip + 3];
            my $car_value = $registers[$car_register_no];
            my $cdr_value = $registers[$cdr_register_no];
            $registers[$target_register_no]
                = make_pair($car_value, $cdr_value);
        }
        elsif ($opcode == SET_PRIM_JOIN_REG_NIL) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $car_register_no = $bytecode->[$ip + 2];
            my $cdr_symbol_id = $bytecode->[$ip + 3];
            my $car_value = $registers[$car_register_no];
            my $cdr_symbol = $SYMBOLS[$cdr_symbol_id];
            $registers[$target_register_no]
                = make_pair($car_value, $cdr_symbol);
        }
        elsif ($opcode == SET_PRIM_JOIN_NIL_NIL) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $car_symbol_id = $bytecode->[$ip + 2];
            my $cdr_symbol_id = $bytecode->[$ip + 3];
            my $car_symbol = $SYMBOLS[$car_symbol_id];
            my $cdr_symbol = $SYMBOLS[$cdr_symbol_id];
            $registers[$target_register_no]
                = make_pair($car_symbol, $cdr_symbol);
        }
        elsif ($opcode == SET_PRIM_TYPE_REG) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $register_no = $bytecode->[$ip + 2];
            my $value = $registers[$register_no];
            $registers[$target_register_no]
                = $bel->{primitives}->prim_type($value);
        }
        elsif ($opcode == SET_REG) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $register_no = $bytecode->[$ip + 2];
            $registers[$target_register_no] = $registers[$register_no];
        }
        elsif ($opcode == SET_SYM) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $symbol_id = $bytecode->[$ip + 2];
            my $symbol = $SYMBOLS[$symbol_id];
            $registers[$target_register_no] = $symbol;
        }
        elsif ($opcode == ERR_IF) {
            my $register_no = $bytecode->[$ip + 1];
            my $value = $registers[$register_no];
            my $symbol_id = $bytecode->[$ip + 2];
            my $symbol = $SYMBOLS[$symbol_id];
            my $symbol_name = symbol_name($symbol);
            if (!is_nil($value)) {
                $bel->{primitives}{err}->($symbol_name);
            }
        }
        elsif ($opcode == RETURN_REG) {
            my $register_no = $bytecode->[$ip + 1];
            my $value = $registers[$register_no];
            return $value;
        }
        elsif ($opcode == RETURN_IF) {
            my $register_no = $bytecode->[$ip + 1];
            my $value = $registers[$register_no];
            if (!is_nil($value)) {
                return $value;
            }
        }
        elsif ($opcode == RETURN_NIL_UNLESS) {
            my $register_no = $bytecode->[$ip + 1];
            my $value = $registers[$register_no];
            if (is_nil($value)) {
                return SYMBOL_NIL;
            }
        }
        elsif ($opcode == RETURN_T_UNLESS) {
            my $register_no = $bytecode->[$ip + 1];
            my $value = $registers[$register_no];
            if (is_nil($value)) {
                return SYMBOL_T;
            }
        }
        else {
            die sprintf("Unknown opcode: 0x%x", $opcode);
        }

        $ip += 4;
    }
}

our @EXPORT_OK = qw(
    apply
    arg_in
    arg_next
    arg_out
    belify_bytefunc
    err_if
    four_groups
    if_jmp
    jmp
    run_bytefunc
    param_instruction
    params
    prim_car
    prim_cdr
    prim_id_reg_sym
    prim_join_nil_nil
    prim_join_reg_nil
    prim_join_reg_reg
    prim_type_reg
    prim_xar
    prim_xdr
    registers_of
    return_if
    return_or_jump
    return_reg
    return_nil_unless
    return_t_unless
    set
    unless_jmp
);

1;
