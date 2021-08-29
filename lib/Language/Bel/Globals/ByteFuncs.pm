package Language::Bel::Globals::ByteFuncs;

use 5.006;
use strict;
use warnings;

use Language::Bel::Bytecode qw(
    IF_JMP
    JMP
    n
    PARAM_IN
    PARAM_LAST
    PARAM_OUT
    PRIM_XAR
    PRIM_XDR
    RETURN_IF
    RETURN_REG
    RETURN_UNLESS
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
use Language::Bel::Pair::ByteFunc qw(
    make_bytefunc
);

use Exporter 'import';

my @all_bytefuncs;
my %bytefuncs;

sub add_bytefunc {
    my ($name, $reg_count, @bytes) = @_;

    my $bytefunc = make_bytefunc($reg_count, [@bytes]);
    push @all_bytefuncs, $name;
    $bytefuncs{$name} = $bytefunc;
}

add_bytefunc("no", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("nil"),
    RETURN_REG, 0, n, n,
);

add_bytefunc("atom", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_TYPE_REG, 0, 0, n,
    SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("pair"),
    SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("nil"),
    RETURN_REG, 0, n, n,
);

add_bytefunc("append", 6,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    SET_PRIM_JOIN_SYM_SYM, 1, SYMBOL("nil"), SYMBOL("nil"),
    SET_REG, 2, 1, n,
    SET_PRIM_CDR, 3, 0, n,
    IF_JMP, 3, 40, n,
    SET_PRIM_CAR, 3, 0, n,
    PRIM_XDR, 1, 3, n,
    SET_PRIM_CDR, 3, 2, n,
    RETURN_REG, 3, n, n,
    SET_PRIM_CAR, 4, 0, n,
    IF_JMP, 4, 56, n,
    SET_REG, 0, 3, n,
    JMP, 16, n, n,
    SET_PRIM_CAR, 5, 4, n,
    SET_PRIM_JOIN_REG_SYM, 5, 5, SYMBOL("nil"),
    PRIM_XDR, 1, 5, n,
    SET_REG, 1, 5, n,
    SET_PRIM_CDR, 4, 4, n,
    PRIM_XAR, 0, 4, n,
    JMP, 20, n, n,
);

add_bytefunc("symbol", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_TYPE_REG, 0, 0, n,
    SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("symbol"),
    RETURN_REG, 0, n, n,
);

add_bytefunc("pair", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_TYPE_REG, 0, 0, n,
    SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("pair"),
    RETURN_REG, 0, n, n,
);

add_bytefunc("char", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_TYPE_REG, 0, 0, n,
    SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("char"),
    RETURN_REG, 0, n, n,
);

add_bytefunc("stream", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_TYPE_REG, 0, 0, n,
    SET_PRIM_ID_REG_SYM, 0, 0, SYMBOL("stream"),
    RETURN_REG, 0, n, n,
);

add_bytefunc("proper", 2,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_ID_REG_SYM, 1, 0, SYMBOL("nil"),
    RETURN_IF, 1, n, n,
    SET_PRIM_TYPE_REG, 1, 0, n,
    SET_PRIM_ID_REG_SYM, 1, 1, SYMBOL("pair"),
    RETURN_UNLESS, 1, n, n,
    SET_PRIM_CDR, 0, 0, n,
    JMP, 16, n, n,
);

add_bytefunc("string", 2,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_ID_REG_SYM, 1, 0, SYMBOL("nil"),
    RETURN_IF, 1, n, n,
    SET_PRIM_TYPE_REG, 1, 0, n,
    SET_PRIM_ID_REG_SYM, 1, 1, SYMBOL("pair"),
    RETURN_UNLESS, 1, n, n,
    SET_PRIM_CAR, 1, 0, n,
    SET_PRIM_TYPE_REG, 1, 1, n,
    SET_PRIM_ID_REG_SYM, 1, 1, SYMBOL("char"),
    RETURN_UNLESS, 1, n, n,
    SET_PRIM_CDR, 0, 0, n,
    JMP, 16, n, n,
);

add_bytefunc("cadr", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_CDR, 0, 0, n,
    SET_PRIM_CAR, 0, 0, n,
    RETURN_REG, 0, n, n,
);

add_bytefunc("cddr", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_CDR, 0, 0, n,
    SET_PRIM_CDR, 0, 0, n,
    RETURN_REG, 0, n, n,
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
