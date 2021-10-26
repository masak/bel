package Language::Bel::Globals::ByteFuncs;

use 5.006;
use strict;
use warnings;

use Language::Bel::Bytecode qw(
    apply
    arg_in
    arg_next
    arg_out
    if_jmp
    jmp
    param_last
    param_next
    param_rest
    prim_car
    prim_cdr
    prim_id_reg_sym
    prim_join_reg_reg
    prim_join_reg_sym
    prim_join_sym_sym
    prim_type_reg
    prim_xar
    prim_xdr
    return_if
    return_reg
    return_nil_unless
    return_t_unless
    set
    unless_jmp
);
use Language::Bel::Pair::ByteFunc qw(
    make_bytefunc
);

use Exporter 'import';

my @all_bytefuncs;
my %bytefuncs;

sub add_bytefunc {
    my ($name, @bytes) = @_;

    my $bytefunc = make_bytefunc([@bytes]);
    push @all_bytefuncs, $name;
    $bytefuncs{$name} = $bytefunc;
}

add_bytefunc("no",
    set(0, param_next()),
    param_last(),
    set(0, prim_id_reg_sym(0, "nil")),
    return_reg(0),
);

add_bytefunc("atom",
    set(0, param_next()),
    param_last(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "pair")),
    set(0, prim_id_reg_sym(0, "nil")),
    return_reg(0),
);

add_bytefunc("all",
    set(0, param_next()),
    set(1, param_next()),
    param_last(),
    return_t_unless(1),
    set(2, prim_car(1)),
    arg_in(),
    arg_next(2),
    arg_out(),
    set(2, apply(0)),
    return_nil_unless(2),
    set(1, prim_cdr(1)),
    jmp(12),
);

add_bytefunc("some",
    set(0, param_next()),
    set(1, param_next()),
    param_last(),
    return_nil_unless(1),
    set(2, prim_car(1)),
    arg_in(),
    arg_next(2),
    arg_out(),
    set(2, apply(0)),
    if_jmp(2, 48),
    set(1, prim_cdr(1)),
    jmp(12),
    return_reg(1),
);

add_bytefunc("reduce",
    set(0, param_next()),
    set(1, param_next()),
    param_last(),
    set(2, "nil"),
    set(3, prim_cdr(1)),
    if_jmp(3, 68),
    set(3, prim_car(1)),
    unless_jmp(2, 64),
    set(1, prim_car(2)),
    arg_in(),
    arg_next(1),
    arg_next(3),
    arg_out(),
    set(3, apply(0)),
    set(2, prim_cdr(2)),
    jmp(28),
    return_reg(3),
    set(3, prim_car(1)),
    set(2, prim_join_reg_reg(3, 2)),
    set(1, prim_cdr(1)),
    jmp(16),
);

add_bytefunc("cons",
    set(0, param_rest()),
    set(1, "nil"),
    set(2, prim_cdr(0)),
    unless_jmp(2, 32),
    set(3, prim_car(0)),
    set(1, prim_join_reg_reg(3, 1)),
    set(0, prim_cdr(0)),
    jmp(8),
    set(2, prim_car(0)),
    unless_jmp(1, 56),
    set(3, prim_car(1)),
    set(2, prim_join_reg_reg(3, 2)),
    set(1, prim_cdr(1)),
    jmp(36),
    return_reg(2),
);

add_bytefunc("append",
    set(0, param_rest()),
    set(1, prim_join_sym_sym("nil", "nil")),
    set(2, 1),
    set(3, prim_cdr(0)),
    if_jmp(3, 36),
    set(3, prim_car(0)),
    prim_xdr(1, 3),
    set(3, prim_cdr(2)),
    return_reg(3),
    set(4, prim_car(0)),
    if_jmp(4, 52),
    set(0, 3),
    jmp(12),
    set(5, prim_car(4)),
    set(5, prim_join_reg_sym(5, "nil")),
    prim_xdr(1, 5),
    set(1, 5),
    set(4, prim_cdr(4)),
    prim_xar(0, 4),
    jmp(16),
);

add_bytefunc("symbol",
    set(0, param_next()),
    param_last(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "symbol")),
    return_reg(0),
);

add_bytefunc("pair",
    set(0, param_next()),
    param_last(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "pair")),
    return_reg(0),
);

add_bytefunc("char",
    set(0, param_next()),
    param_last(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "char")),
    return_reg(0),
);

add_bytefunc("stream",
    set(0, param_next()),
    param_last(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "stream")),
    return_reg(0),
);

add_bytefunc("proper",
    set(0, param_next()),
    param_last(),
    set(1, prim_id_reg_sym(0, "nil")),
    return_if(1),
    set(1, prim_type_reg(0)),
    set(1, prim_id_reg_sym(1, "pair")),
    return_nil_unless(1),
    set(0, prim_cdr(0)),
    jmp(8),
);

add_bytefunc("string",
    set(0, param_next()),
    param_last(),
    set(1, prim_id_reg_sym(0, "nil")),
    return_if(1),
    set(1, prim_type_reg(0)),
    set(1, prim_id_reg_sym(1, "pair")),
    return_nil_unless(1),
    set(1, prim_car(0)),
    set(1, prim_type_reg(1)),
    set(1, prim_id_reg_sym(1, "char")),
    return_nil_unless(1),
    set(0, prim_cdr(0)),
    jmp(8),
);

add_bytefunc("cadr",
    set(0, param_next()),
    param_last(),
    set(0, prim_cdr(0)),
    set(0, prim_car(0)),
    return_reg(0),
);

add_bytefunc("cddr",
    set(0, param_next()),
    param_last(),
    set(0, prim_cdr(0)),
    set(0, prim_cdr(0)),
    return_reg(0),
);

add_bytefunc("caddr",
    set(0, param_next()),
    param_last(),
    set(0, prim_cdr(0)),
    set(0, prim_cdr(0)),
    set(0, prim_car(0)),
    return_reg(0),
);

add_bytefunc("rev",
    set(0, param_next()),
    param_last(),
    set(1, "nil"),
    if_jmp(0, 20),
    return_reg(1),
    set(2, prim_car(0)),
    set(1, prim_join_reg_reg(2, 1)),
    set(0, prim_cdr(0)),
    jmp(12),
);

sub all_bytefuncs {
    return @all_bytefuncs;
}

sub bytefunc {
    my ($name) = @_;

    return $bytefuncs{$name};
}

our @EXPORT_OK = qw(
    all_bytefuncs
    bytefunc
);

1;
