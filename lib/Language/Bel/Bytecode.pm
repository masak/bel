package Language::Bel::Bytecode;

use 5.006;
use strict;
use warnings;

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

sub PARAM_IN { 0x00 }
sub PARAM_NEXT { 0x01 }
sub SET_PARAM_NEXT { 0x02 }
sub PARAM_LAST { 0x03 }
sub PARAM_OUT { 0x04 }

sub PRIM_XAR { 0x10 }
sub PRIM_XDR { 0x11 }
sub PRIM_CAR { 0x12 }
sub PRIM_CDR { 0x13 }
sub PRIM_ID_REG_SYM { 0x14 }
sub PRIM_JOIN_REG_REG { 0x15 }
sub PRIM_JOIN_REG_SYM { 0x16 }
sub PRIM_JOIN_SYM_SYM { 0x17 }
sub PRIM_TYPE_REG { 0x18 }

sub SET_PRIM_CAR { 0x22 }
sub SET_PRIM_CDR { 0x23 }
sub SET_PRIM_ID_REG_SYM { 0x24 }
sub SET_PRIM_JOIN_REG_REG { 0x25 }
sub SET_PRIM_JOIN_REG_SYM { 0x26 }
sub SET_PRIM_JOIN_SYM_SYM { 0x27 }
sub SET_PRIM_TYPE_REG { 0x28 }

sub SET_REG { 0x30 }
sub SET_SYM { 0x31 }

sub JMP { 0x40 }
sub IF_JMP { 0x41 }

sub RETURN_REG { 0xF0 }
sub RETURN_IF { 0xF1 }
sub RETURN_UNLESS { 0xF2 }

my @registered_symbols = (
    "nil",
    "t",
    "pair",
    "symbol",
    "char",
    "stream",
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

my @PARAM_OPCODES = (
    PARAM_IN,
    PARAM_LAST,
    PARAM_NEXT,
    PARAM_OUT,
    SET_PARAM_NEXT,
);

sub param_instruction {
    my ($opcode) = @_;

    return in($opcode, @PARAM_OPCODES);
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

sub jmp {
    die "`jmp` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($target_ip) = @_;

    die "Illegal instruction pointer argument to `jmp`"
        unless operand_is_instruction_pointer($target_ip);

    return (JMP, $target_ip, 0, 0);
}

sub param_in {
    die "`param_in` instruction expects no operands"
        unless @_ == 0;

    return (PARAM_IN, 0, 0, 0);
}

sub param_last {
    die "`param_last` instruction expects no operands"
        unless @_ == 0;

    return (PARAM_LAST, 0, 0, 0);
}

sub param_next {
    die "`param_next` instruction expects no operands"
        unless @_ == 0;

    return (PARAM_NEXT, 0, 0, 0);
}

sub param_out {
    die "`param_out` instruction expects no operands"
        unless @_ == 0;

    return (PARAM_OUT, 0, 0, 0);
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

sub prim_join_reg_sym {
    die "`prim_join_reg_sym` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($register, $symbol) = @_;

    die "Illegal register argument to `prim_join_reg_sym`"
        unless operand_is_register($register);
    die "Illegal symbol argument to `prim_join_reg_sym`"
        unless operand_is_symbol($symbol);

    return (PRIM_JOIN_REG_SYM, $register, SYMBOL($symbol), 0);
}

sub prim_join_sym_sym {
    die "`prim_join_sym_sym` instruction expects exactly 2 operands"
        unless @_ == 2;

    my ($symbol1, $symbol2) = @_;

    die "Illegal first symbol argument to `prim_join_sym_sym`"
        unless operand_is_symbol($symbol1);
    die "Illegal second symbol argument to `prim_join_sym_sym`"
        unless operand_is_symbol($symbol2);

    return (PRIM_JOIN_SYM_SYM, SYMBOL($symbol1), SYMBOL($symbol2), 0);
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

sub return_unless {
    die "`return_unless` instruction expects exactly 1 operand"
        unless @_ == 1;

    my ($register) = @_;

    die "Illegal register argument to `return_unless`"
        unless operand_is_register($register);

    return (RETURN_UNLESS, $register, 0, 0);
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

        my $set_op = $op == PARAM_NEXT ? SET_PARAM_NEXT
            : $op == PRIM_CAR ? SET_PRIM_CAR
            : $op == PRIM_CDR ? SET_PRIM_CDR
            : $op == PRIM_ID_REG_SYM ? SET_PRIM_ID_REG_SYM
            : $op == PRIM_TYPE_REG ? SET_PRIM_TYPE_REG
            : $op == PRIM_JOIN_REG_REG ? SET_PRIM_JOIN_REG_REG
            : $op == PRIM_JOIN_REG_SYM ? SET_PRIM_JOIN_REG_SYM
            : $op == PRIM_JOIN_SYM_SYM ? SET_PRIM_JOIN_SYM_SYM
            : -1;
        die "Unexpected underlying op to `set`: ", sprintf("0x%02x", $op)
            if $set_op == -1;

        return ($set_op, $register, $r1, $r2);
    }
}

sub has_0_operands {
    my ($opcode) = @_;

    return in($opcode,
        PARAM_IN, PARAM_NEXT, PARAM_LAST, PARAM_OUT, JMP, SET_SYM);
}

sub has_1_operands {
    my ($opcode) = @_;

    return in($opcode,
        RETURN_IF, RETURN_REG, RETURN_UNLESS, SET_PARAM_NEXT,
        SET_PRIM_JOIN_SYM_SYM, IF_JMP);
}

sub has_2_operands {
    my ($opcode) = @_;

    return in($opcode, PRIM_XAR, PRIM_XDR, SET_PRIM_TYPE_REG,
        SET_PRIM_ID_REG_SYM, SET_PRIM_JOIN_REG_SYM, SET_REG,
        SET_PRIM_CAR, SET_PRIM_CDR);
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
    elsif (has_1_operands($opcode)) {
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

    if ($opcode == PARAM_IN) {
        return "(param!in)";
    }
    elsif ($opcode == PARAM_NEXT) {
        return "(param!next)";
    }
    elsif ($opcode == SET_PARAM_NEXT) {
        my $target = "%$o1";
        return "($target := param!next)";
    }
    elsif ($opcode == PARAM_LAST) {
        return "(param!last)";
    }
    elsif ($opcode == PARAM_OUT) {
        return "(param!out)";
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
    elsif ($opcode == RETURN_REG) {
        my $reg = "%$o1";
        return "(return $reg)";
    }
    else {
        die "Unknown opcode $opcode";
    }
}

sub symbol_of {
    my ($index) = @_;
    if ($index < 0 || scalar(@registered_symbols) < $index) {
        die "Symbol index `$index` out of bounds";
    }
    return $registered_symbols[$index];
}

sub run_bytefunc {
    my ($bytecode, $reg_count, $bel, @args) = @_;

    my $ip = 0;
    my @registers = ("<uninitialized>") x $reg_count;
    my $param_level = 0;
    my $arg1;
    while (1) {
        my $opcode = $bytecode->[$ip];
        if ($opcode == PARAM_IN) {
            $param_level += 1;
            $arg1 = shift(@args);
        }
        elsif ($opcode == SET_PARAM_NEXT) {
            my $reg_no = $bytecode->[$ip + 1];
            if ($param_level == 0) {
                $registers[$reg_no] = shift(@args);
            }
            elsif ($param_level == 1) {
                die "Underargs\n"
                    if is_nil($arg1);
                $registers[$reg_no] = $bel->car($arg1);
                $arg1 = $bel->cdr($arg1);
            }
            else {
                die "Unrecognized level $param_level\n";
            }
        }
        elsif ($opcode == PARAM_LAST) {
            if ($param_level == 1) {
                die "Overargs\n"
                    unless is_nil($arg1);
            }
        }
        elsif ($opcode == PARAM_OUT) {
            $param_level -= 1;
            $arg1 = undef;
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
        elsif ($opcode == SET_PRIM_JOIN_REG_SYM) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $car_register_no = $bytecode->[$ip + 2];
            my $cdr_symbol_id = $bytecode->[$ip + 3];
            my $car_value = $registers[$car_register_no];
            my $cdr_symbol = $SYMBOLS[$cdr_symbol_id];
            $registers[$target_register_no]
                = make_pair($car_value, $cdr_symbol);
        }
        elsif ($opcode == SET_PRIM_JOIN_SYM_SYM) {
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
        elsif ($opcode == RETURN_UNLESS) {
            my $register_no = $bytecode->[$ip + 1];
            my $value = $registers[$register_no];
            if (is_nil($value)) {
                return SYMBOL_NIL;
            }
        }
        else {
            die "Uncrecognized opcode: ", $opcode;
        }

        $ip += 4;
    }
}

our @EXPORT_OK = qw(
    belify_bytefunc
    four_groups
    has_0_operands
    has_1_operands
    has_2_operands
    has_3_operands
    if_jmp
    jmp
    run_bytefunc
    param_instruction
    param_in
    param_last
    param_next
    param_out
    prim_car
    prim_cdr
    prim_id_reg_sym
    prim_join_reg_reg
    prim_join_reg_sym
    prim_join_sym_sym
    prim_type_reg
    prim_xar
    prim_xdr
    registers_of
    return_if
    return_or_jump
    return_reg
    return_unless
    set
);

1;
