package Language::Bel::Globals::ByteFuncs;

use 5.006;
use strict;
use warnings;

use Language::Bel::Bytecode qw(
    if_jmp
    jmp
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
    return_if
    return_reg
    return_unless
    set
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
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_id_reg_sym(0, "nil")),
    return_reg(0),
);

add_bytefunc("atom",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "pair")),
    set(0, prim_id_reg_sym(0, "nil")),
    return_reg(0),
);

add_bytefunc("append",
    set(0, param_next()),
    param_last(),
    set(1, prim_join_sym_sym("nil", "nil")),
    set(2, 1),
    set(3, prim_cdr(0)),
    if_jmp(3, 40),
    set(3, prim_car(0)),
    prim_xdr(1, 3),
    set(3, prim_cdr(2)),
    return_reg(3),
    set(4, prim_car(0)),
    if_jmp(4, 56),
    set(0, 3),
    jmp(16),
    set(5, prim_car(4)),
    set(5, prim_join_reg_sym(5, "nil")),
    prim_xdr(1, 5),
    set(1, 5),
    set(4, prim_cdr(4)),
    prim_xar(0, 4),
    jmp(20),
);

add_bytefunc("symbol",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "symbol")),
    return_reg(0),
);

add_bytefunc("pair",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "pair")),
    return_reg(0),
);

add_bytefunc("char",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "char")),
    return_reg(0),
);

add_bytefunc("stream",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_type_reg(0)),
    set(0, prim_id_reg_sym(0, "stream")),
    return_reg(0),
);

add_bytefunc("proper",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(1, prim_id_reg_sym(0, "nil")),
    return_if(1),
    set(1, prim_type_reg(0)),
    set(1, prim_id_reg_sym(1, "pair")),
    return_unless(1),
    set(0, prim_cdr(0)),
    jmp(16),
);

add_bytefunc("string",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(1, prim_id_reg_sym(0, "nil")),
    return_if(1),
    set(1, prim_type_reg(0)),
    set(1, prim_id_reg_sym(1, "pair")),
    return_unless(1),
    set(1, prim_car(0)),
    set(1, prim_type_reg(1)),
    set(1, prim_id_reg_sym(1, "char")),
    return_unless(1),
    set(0, prim_cdr(0)),
    jmp(16),
);

add_bytefunc("cadr",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_cdr(0)),
    set(0, prim_car(0)),
    return_reg(0),
);

add_bytefunc("cddr",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_cdr(0)),
    set(0, prim_cdr(0)),
    return_reg(0),
);

add_bytefunc("caddr",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(0, prim_cdr(0)),
    set(0, prim_cdr(0)),
    set(0, prim_car(0)),
    return_reg(0),
);

add_bytefunc("rev",
    param_in(),
    set(0, param_next()),
    param_last(),
    param_out(),
    set(1, "nil"),
    if_jmp(0, 28),
    return_reg(1),
    set(2, prim_car(0)),
    set(1, prim_join_reg_reg(2, 1)),
    set(0, prim_cdr(0)),
    jmp(20),
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
