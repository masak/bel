package Language::Bel::Compiler;

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
use Language::Bel::Primitives;
use Language::Bel::Printer qw(
    _print
);
use Language::Bel::Reader qw(
    read_whole
);

use Exporter 'import';

{
    my $primitives = Language::Bel::Primitives->new({
        output => sub {},
        read_char => sub {},
        err => sub {
            my ($message_str) = @_;

            die "Error during compilation: $message_str\n";
        },
    });

    sub car {
        my ($pair) = @_;

        return $primitives->prim_car($pair);
    }

    sub cdr {
        my ($pair) = @_;

        return $primitives->prim_cdr($pair);
    }
}

my %arg_count_of = (
    "id" => 2,
    "type" => 1,
);

sub is_primitive {
    my ($op) = @_;

    return
        unless is_symbol($op);
    my $name = symbol_name($op);
    return !!$arg_count_of{$name};
}

my $unique_gensym_index = 0;

my $GENSYM_PREFIX = "gensym_";

sub gensym {
    return $GENSYM_PREFIX . sprintf("%04d", ++$unique_gensym_index);
}

sub is_gensym {
    my ($expr) = @_;

    return is_symbol($expr)
        && substr(symbol_name($expr), 0, length($GENSYM_PREFIX))
            eq $GENSYM_PREFIX;
}

sub handle_primitive {
    my ($op, $instructions_ref, @args) = @_;

    my $name = symbol_name($op);
    my $expected_arg_count = $arg_count_of{$name};
    my $actual_arg_count = scalar(@args);
    die "Expected $expected_arg_count for primitive `$name`, "
        . "got $actual_arg_count"
        unless $actual_arg_count == $expected_arg_count;
    my $a0_gensym = handle_expression($args[0], $instructions_ref);
    my $target_gensym = gensym();
    if ($name eq "id") {
        my $symbol;
        if (is_nil($args[1])) {
            $symbol = "nil";
        }
        elsif (is_pair($args[1])
            && is_symbol_of_name(car($args[1]), "quote")) {
            my $quote_cadr = car(cdr($args[1]));
            die "The quoted thing is not a symbol: ", _print($args[1])
                unless is_symbol($quote_cadr);
            $symbol = symbol_name($quote_cadr);
        }
        else {
            die "Unexpected not-a-symbol";
        }

        push @{$instructions_ref},
            read_whole("($target_gensym := (prim!id $a0_gensym '$symbol))");
    }
    elsif ($name eq "type") {
        push @{$instructions_ref},
            read_whole("($target_gensym := (prim!type $a0_gensym))");
    }
    else {
        die "Unexpected primitive `$name`";
    }
    return $target_gensym;
}

sub handle_expression {
    my ($expr, $instructions_ref) = @_;

    if (is_symbol($expr)) {
        return symbol_name($expr);
    }

    my $op = car($expr);
    my $args = cdr($expr);
    my @args;
    while (!is_nil($args)) {
        push @args, car($args);
        $args = cdr($args);
    }

    my $target_gensym;
    if (is_primitive($op)) {
        $target_gensym = handle_primitive($op, $instructions_ref, @args);
    }
    elsif (is_symbol_of_name($op, "no")) {
        if (scalar(@args) != 1) {
            die "expected 1 arg: ", _print($expr);
        }
        $target_gensym = gensym();
        my $a0_gensym = handle_expression($args[0], $instructions_ref);
        push @{$instructions_ref},
            read_whole("($target_gensym := (prim!id $a0_gensym 'nil))");
    }
    else {
        die "unexpected: ", _print($expr);
    }

    return $target_gensym;
}

sub replace_variables {
    my ($ast, $translation_ref) = @_;

    if (is_symbol($ast)) {
        my $name = symbol_name($ast);
        return $translation_ref->{$name} || $ast;
    }
    elsif (is_pair($ast)) {
        my $car = replace_variables(car($ast), $translation_ref);
        my $cdr = replace_variables(cdr($ast), $translation_ref);
        return make_pair($car, $cdr);
    }
    else {
        die "Unexpected type: ", _print($ast);
    }
}

sub nanopass_01_alpha {
    my ($ast) = @_;

    $ast = cdr($ast);
    my $fn_name = car($ast);

    $ast = cdr($ast);
    my $args = car($ast);

    die "Not general enough to handle these args yet: ", _print($args)
        unless is_pair($args)
            && is_symbol(car($args))
            && is_nil(cdr($args));

    my $single_param_name = symbol_name(car($args));

    my $gensym = make_symbol(gensym());

    my $body = cdr($ast);
    my %translation = (
        $single_param_name => $gensym,
    );

    return make_pair(
        make_symbol("def-01"),
        make_pair(
            $fn_name,
            make_pair(
                make_pair(
                    $gensym,
                    SYMBOL_NIL,
                ),
                replace_variables($body, \%translation),
            ),
        ),
    );
}

sub listify {
    my (@elems) = @_;

    my $list = SYMBOL_NIL;
    for my $elem (reverse(@elems)) {
        $list = make_pair($elem, $list);
    }

    return $list;
}

sub nanopass_02_flatten {
    my ($ast) = @_;

    $ast = cdr($ast);
    # skipping $fn_name

    $ast = cdr($ast);
    my $args = car($ast);

    my $body = cdr($ast);

    my @instructions;
    my $final_target_gensym = "<not set>";
    while (!is_nil($body)) {
        my $statement = car($body);
        $final_target_gensym = handle_expression($statement, \@instructions);
        $body = cdr($body);
    }

    if ($final_target_gensym eq "<not set>") {
        die "XXX need to handle this case, when the body is `nil`";
    }

    push @instructions, read_whole("(return $final_target_gensym)");

    return make_pair(
        make_symbol("def-02"),
        make_pair(
            $args,
            listify(@instructions),
        ),
    );
}

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
        my $symbol_name = symbol_name($expr);
        push @{$captures_ref}, $symbol_name;
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
                    SET_PRIM_ID_REG_SYM, $reg1, $reg2, SYMBOL($sym),
                );
            },

            "(% := (prim!type %))",
            sub { my ($reg1, $reg2) = @_;
                push @bytes, (
                    SET_PRIM_TYPE_REG, $reg1, $reg2, n,
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
