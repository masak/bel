package Language::Bel::Bytecode;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub PARAM_IN { 0x00 }
sub PARAM_NEXT { 0x01 }
sub SET_PARAM_NEXT { 0x02 }
sub PARAM_LAST { 0x03 }
sub PARAM_OUT { 0x04 }

sub PRIM_XAR { 0x10 }
sub PRIM_XDR { 0x11 }
sub SET_PRIM_CAR { 0x12 }
sub SET_PRIM_CDR { 0x13 }
sub SET_PRIM_ID_REG_SYM { 0x14 }
sub SET_PRIM_JOIN_REG_SYM { 0x15 }
sub SET_PRIM_JOIN_SYM_SYM { 0x16 }
sub SET_PRIM_TYPE_REG { 0x17 }

sub SET_REG { 0x20 }
sub SET_SYM { 0x21 }

sub JMP { 0x30 }
sub IF_JMP { 0x31 }

sub RETURN_REG { 0xF0 }

my @registered_symbols = (
    "nil",
    "t",
    "pair",
    "symbol",
);

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

sub n { 0 }

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

sub belify_bytefunc {
    my ($bytefunc) = @_;

    my $r = $bytefunc->reg_count();
    my @ops = ops($bytefunc);
    my @instructions = map { belify_instruction($_) } @ops;
    my $instructions = join "", map { "\n  $_" } @instructions;

    return "(bytefunc $r$instructions)\n";
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

our @EXPORT_OK = qw(
    belify_bytefunc
    IF_JMP
    JMP
    n
    PARAM_IN
    PARAM_LAST
    PARAM_NEXT
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
    SET_SYM
    SYMBOL
);

1;
