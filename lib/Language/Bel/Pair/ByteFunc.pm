package Language::Bel::Pair::ByteFunc;
use base qw(Language::Bel::Pair);

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
use Language::Bel::Bytecode qw(
    IF_JMP
    JMP
    n
    PARAM_IN
    PARAM_LAST
    PARAM_OUT
    PRIM_XAR
    PRIM_XDR
    RETURN_REG
    SET_PARAM_NEXT
    SET_PRIM_CAR
    SET_PRIM_CDR
    SET_PRIM_ID_REG_SYM
    SET_PRIM_JOIN_REG_SYM
    SET_PRIM_JOIN_SYM_SYM
    SET_PRIM_TYPE_REG
    SET_REG
);
use Exporter 'import';

my @SYMBOLS = (
    make_symbol("nil"),
    make_symbol("t"),
    make_symbol("pair"),
    make_symbol("symbol"),
    make_symbol("char"),
);

sub new {
    my ($class, $reg_count, $bytes) = @_;

    my $obj = {
        reg_count => $reg_count,
        bytes => $bytes,
    };
    return bless($obj, $class);
}

sub car {
    my ($self) = @_;

    return SYMBOL_NIL;
}

sub cdr {
    my ($self) = @_;

    return SYMBOL_NIL;
}

sub xar {
    my ($self, $car) = @_;

    die "Attempted to modify a bytefunc\n";
}

sub xdr {
    my ($self, $cdr) = @_;

    die "Attempted to modify a bytefunc\n";
}

sub apply {
    my ($self, $bel, @args) = @_;

    my $bytecode = $self->{bytes};
    my $ip = 0;
    my @registers = 0 x $self->{reg_count};
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
        elsif ($opcode == RETURN_REG) {
            my $register_no = $bytecode->[$ip + 1];
            my $value = $registers[$register_no];
            return $value;
        }
        else {
            die "Uncrecognized opcode: ", $opcode;
        }

        $ip += 4;
    }
}

sub reg_count {
    my ($self) = @_;

    return $self->{reg_count};
}

sub bytes {
    my ($self) = @_;

    return $self->{bytes};
}

sub is_bytefunc {
    my ($object) = @_;

    return $object->isa(__PACKAGE__);
}

sub make_bytefunc {
    my ($regcount, $bytes) = @_;

    return __PACKAGE__->new($regcount, $bytes);
}

our @EXPORT_OK = qw(
    is_bytefunc
    make_bytefunc
);

1;
