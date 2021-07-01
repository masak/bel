package Language::Bel::Globals::Bytecode;

use 5.006;
use strict;
use warnings;

use Language::Bel::Bytecode qw(
    n
    PARAM_IN
    PARAM_LAST
    PARAM_OUT
    RETURN_REG
    SET_PARAM_NEXT
    SET_PRIM_ID_REG_SYM
    SET_PRIM_TYPE_REG
    SYM_NIL
    SYM_PAIR
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
    SET_PRIM_ID_REG_SYM, 0, 0, SYM_NIL,
    RETURN_REG, 0, n, n,
);

add_bytefunc("atom", 1,
    PARAM_IN, n, n, n,
    SET_PARAM_NEXT, 0, n, n,
    PARAM_LAST, n, n, n,
    PARAM_OUT, n, n, n,
    SET_PRIM_TYPE_REG, 0, 0, n,
    SET_PRIM_ID_REG_SYM, 0, 0, SYM_PAIR,
    SET_PRIM_ID_REG_SYM, 0, 0, SYM_NIL,
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
