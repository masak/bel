package Language::Bel::Pair::ByteFunc;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    is_nil
    is_symbol
    make_symbol
    SYMBOL_NIL
    SYMBOL_T
    symbol_name
);
use Language::Bel::Bytecode qw(
    n
    PARAM_IN
    PARAM_LAST
    PARAM_OUT
    RETURN_REG
    SET_PARAM_NEXT
    SET_PRIM_ID_REG_SYM
    SET_PRIM_TYPE_REG
);
use Exporter 'import';

my @SYMBOLS = (
    make_symbol("nil"),
    make_symbol("t"),
    make_symbol("pair"),
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
    my ($self, $bel, $args) = @_;

    my $bytecode = $self->{bytes};
    my $ip = 0;
    my @registers = 0 x $self->{reg_count};
    while (1) {
        my $opcode = $bytecode->[$ip];
        if ($opcode == PARAM_IN) {
            # ignoring this one for now, since we don't have `args` or
            # nested arguments
        }
        elsif ($opcode == SET_PARAM_NEXT) {
            die "Underargs\n"
                if is_nil($args);
            my $reg_no = $bytecode->[$ip + 1];
            $registers[$reg_no] = $bel->car($args);
            $args = $bel->cdr($args);
        }
        elsif ($opcode == PARAM_LAST) {
            die "Overargs\n"
                unless is_nil($args);
        }
        elsif ($opcode == PARAM_OUT) {
            # ignoring this one for now, since we don't have `args` or
            # nested arguments
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
        elsif ($opcode == SET_PRIM_TYPE_REG) {
            my $target_register_no = $bytecode->[$ip + 1];
            my $register_no = $bytecode->[$ip + 2];
            my $value = $registers[$register_no];
            $registers[$target_register_no]
                = $bel->{primitives}->prim_type($value);
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
