package Language::Bel::Compiler;

use 5.006;
use strict;
use warnings;

use Language::Bel::Bytecode qw(
    n
    PARAM_IN
    PARAM_LAST
    PARAM_NEXT
    PARAM_OUT
    RETURN_REG
    SET_PARAM_NEXT
    SET_PRIM_ID_REG_SYM
    SET_PRIM_TYPE_REG
    SET_SYM
    SYMBOL
);
use Language::Bel::Pair::ByteFunc qw(
    make_bytefunc
);
use Language::Bel::Core qw(
    is_nil
    is_pair
    is_symbol
    is_symbol_of_name
    make_pair
    make_symbol
    symbol_name
    SYMBOL_NIL
);
use Language::Bel::Printer qw(
    _print
);
use Language::Bel::Reader qw(
    read_whole
);
use Language::Bel::Compiler::Gensym qw(
    gensym
    is_gensym
);
use Language::Bel::Compiler::Pass01 qw(
    nanopass_01_alpha
);
use Language::Bel::Compiler::Pass02 qw(
    nanopass_02_flatten
);
use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);

use Exporter 'import';

sub substitute_registers {
    my ($expr) = @_;

    if (is_symbol($expr) && is_gensym($expr)) {
        return make_symbol("%0");
    }
    elsif (is_pair($expr)) {
        return make_pair(
            substitute_registers(car($expr)),
            substitute_registers(cdr($expr)),
        );
    }
    else {
        return $expr;
    }
}

sub nanopass_03_allocate_registers {
    my ($ast) = @_;

    $ast = cdr($ast);
    my $args = substitute_registers(car($ast));

    my $body = cdr($ast);

    return make_pair(
        make_symbol("def-03"),
        make_pair(
            $args,
            substitute_registers($body),
        ),
    );
}

sub ast_match {
    my ($expr, $match_ast, $captures_ref) = @_;

    if (is_pair($expr) && is_pair($match_ast)) {
        return ast_match(car($expr), car($match_ast), $captures_ref)
            && ast_match(cdr($expr), cdr($match_ast), $captures_ref);
    }
    elsif (is_symbol($expr) && substr(symbol_name($expr), 0, 1) eq "%"
            && is_symbol($match_ast) && symbol_name($match_ast) eq "%") {
        my $register_number = substr(symbol_name($expr), 1);
        push @{$captures_ref}, $register_number;
        return 1;
    }
    elsif (is_symbol($expr) && is_symbol($match_ast)
            && symbol_name($expr) eq symbol_name($match_ast)) {
        return 1;
    }
    elsif (is_symbol($expr) && is_symbol($match_ast)
            && symbol_name($match_ast) eq "<sym>") {
        my $symbol_id = SYMBOL(symbol_name($expr));
        push @{$captures_ref}, $symbol_id;
        return 1;
    }
    else {
        return 0;
    }
}

sub statement_match {
    my ($statement, $match_str, $consequent, @rest) = @_;

    my $match_ast = read_whole($match_str);
    my $captures_ref = [];
    if (ast_match($statement, $match_ast, $captures_ref)) {
        my @captures = @{$captures_ref};
        $consequent->(@captures);
    }
    elsif (scalar(@rest) == 0) {
        die "Couldn't match ", _print($statement);
    }
    else {
        statement_match($statement, @rest);
    }
}

sub serialize_bytefunc {
    my ($ast) = @_;

    $ast = cdr($ast);
    my $args = substitute_registers(car($ast));

    my $body = cdr($ast);

    my $reg_count = 1;
    my @bytes = (
        PARAM_IN, n, n, n,
        SET_PARAM_NEXT, 0, n, n,
        PARAM_LAST, n, n, n,
        PARAM_OUT, n, n, n,
    );

    while (!is_nil($body)) {
        my $statement = car($body);
        # (%0 (compose =) ((prim (quote id)) %0 (quote nil)))
        statement_match(
            $statement,

            "(% := (prim!id % '<sym>))",
            sub { my ($reg1, $reg2, $sym) = @_;
                push @bytes, (
                    SET_PRIM_ID_REG_SYM, $reg1, $reg2, $sym,
                );
            },

            "(% := (prim!type %))",
            sub { my ($reg1, $reg2) = @_;
                push @bytes, (
                    SET_PRIM_TYPE_REG, $reg1, $reg2, n,
                );
            },

            "(% := '<sym>)",
            sub { my ($reg, $sym) = @_;
                push @bytes, (
                    SET_SYM, $reg, $sym, n,
                );
            },

            "(return %)",
            sub { my ($reg) = @_;
                push @bytes, (
                    RETURN_REG, $reg, n, n,
                );
            },
        );

        $body = cdr($body);
    }

    # A little brittle, but it'll work for now
    if (scalar(@bytes) == 4 * 6 && $bytes[4 * 4] == SET_SYM) {
        $bytes[4 * 1 + 0] = PARAM_NEXT;
        $bytes[4 * 1 + 1] = n;
    }

    return make_bytefunc($reg_count, [@bytes]);
}

sub compile {
    my ($source) = @_;

    my $_00 = read_whole($source);
    my $_01 = nanopass_01_alpha($_00);
    my $_02 = nanopass_02_flatten($_01);
    my $_03 = nanopass_03_allocate_registers($_02);

    return serialize_bytefunc($_03);
}

our @EXPORT_OK = qw(
    compile
);

1;
