package Language::Bel::Compiler::Pass::AllocateRegisters;
use base qw(Language::Bel::Compiler::Pass);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    is_pair
    is_symbol
    make_pair
    make_symbol
);
use Language::Bel::Compiler::Gensym qw(
    is_gensym
);
use Language::Bel::Compiler::Primitives qw(
    car
    cdr
);

sub new {
    my ($class) = @_;

    return $class->SUPER::new("allocate-registers");
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

# @override
sub do_translate {
    my ($self, $ast) = @_;

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

1;
