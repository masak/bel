package Language::Bel::Compiler;

use 5.006;
use strict;
use warnings;

use Language::Bel::Bytecode qw(
    param_last
    param_next
    prim_id_reg_sym
    prim_type_reg
    return_reg
    set
);
use Language::Bel::Pair::ByteFunc qw(
    make_bytefunc
);
use Language::Bel::Core qw(
    is_nil
    is_pair
    is_symbol
    symbol_name
);
use Language::Bel::Printer qw(
    _print
);
use Language::Bel::Reader qw(
    read_whole
);
use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);

use Exporter 'import';

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
        push @{$captures_ref}, symbol_name($expr);
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

sub is_set_sym {
    my ($opcode) = @_;

    my @bytes = set(0, "nil");
    return $opcode == $bytes[0];
}

sub generate_bytefunc {
    my ($ast) = @_;

    $ast = cdr($ast);
    # ignore argument list for now

    my $body = cdr($ast);

    my $reg_count = 1;
    my @bytes = (
        set(0, param_next()),
        param_last(),
    );

    while (!is_nil($body)) {
        my $statement = car($body);
        # (%0 (compose =) ((prim (quote id)) %0 (quote nil)))
        statement_match(
            $statement,

            "(% := (prim!id % '<sym>))",
            sub { my ($reg1, $reg2, $sym) = @_;
                push @bytes, set($reg1, prim_id_reg_sym($reg2, $sym));
            },

            "(% := (prim!type %))",
            sub { my ($reg1, $reg2) = @_;
                push @bytes, set($reg1, prim_type_reg($reg2));
            },

            "(% := '<sym>)",
            sub { my ($reg, $sym) = @_;
                push @bytes, set($reg, $sym);
            },

            "(return %)",
            sub { my ($reg) = @_;
                push @bytes, return_reg($reg);
            },
        );

        $body = cdr($body);
    }

    # A little brittle, but it'll work for now
    if (scalar(@bytes) == 4 * 4 && is_set_sym($bytes[4 * 2])) {
        @bytes[4*0 .. 4*0+3] = param_next();
    }

    return make_bytefunc([@bytes]);
}

our @EXPORT_OK = qw(
    generate_bytefunc
);

1;
