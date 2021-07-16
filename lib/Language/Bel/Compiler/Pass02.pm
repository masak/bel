package Language::Bel::Compiler::Pass02;
use base qw(Language::Bel::Compiler::Pass);

use 5.006;
use strict;
use warnings;

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
);
use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);

my %arg_count_of = (
    "id" => 2,
    "type" => 1,
);

sub new {
    my ($class) = @_;

    return $class->SUPER::new("flatten");
}

sub is_primitive {
    my ($op) = @_;

    return
        unless is_symbol($op);
    my $name = symbol_name($op);
    return !!$arg_count_of{$name};
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

sub listify {
    my (@elems) = @_;

    my $list = SYMBOL_NIL;
    for my $elem (reverse(@elems)) {
        $list = make_pair($elem, $list);
    }

    return $list;
}

sub translate {
    my ($self, $ast) = @_;

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
        my $target_gensym = gensym();
        push @instructions, read_whole("($target_gensym := 'nil)");
        $final_target_gensym = $target_gensym;
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

1;
