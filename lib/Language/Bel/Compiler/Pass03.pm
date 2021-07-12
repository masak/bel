package Language::Bel::Compiler::Pass03;

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

our @EXPORT_OK = qw(
    nanopass_03_allocate_registers
);

1;
