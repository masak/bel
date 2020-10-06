#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Globals::FastFuncs::Preprocessor qw(
    expand
);

plan tests => 5;

my $INDENT = " " x 4;

{
    my $input = $INDENT . "return NIL;\n";
    my $expected_output = $INDENT . "return SYMBOL_NIL;\n";

    my $actual_output = expand($input);

    is $actual_output, $expected_output, "NIL expands to SYMBOL_NIL";
}

{
    my $input = $INDENT . "return T;\n";
    my $expected_output = $INDENT . "return SYMBOL_T;\n";

    my $actual_output = expand($input);

    is $actual_output, $expected_output, "T expands to SYMBOL_T";
}

{
    my $input = <<'EOF';
    my ($bel, $x) = @_;

    return is_nil($x) ? T : NIL;
EOF

    my $expected_output = <<'EOF';
    my ($bel, $x) = @_;

    return is_nil($x) ? SYMBOL_T : SYMBOL_NIL;
EOF

    my $actual_output = expand($input);

    is $actual_output, $expected_output, "expansion of fastfunc__no";
}

{
    my $input = <<'EOF';
    my ($bel, $f, $xs) = @_;

    my $x;
    ITERATE_FORWARD($x, $xs, sub {
        UNLESS(CALL($f, $x), sub {
            return NIL;
        });
    });

    return T;
EOF

    my $expected_output = <<'EOF';
    my ($bel, $f, $xs) = @_;

    while (!is_nil($xs)) {
        if (is_nil($bel->call($f, $bel->car($xs)))) {
            return SYMBOL_NIL;
        }
        $xs = $bel->cdr($xs);
    }

    return SYMBOL_T;
EOF

    my $actual_output = expand($input);

    is $actual_output, $expected_output, "expansion of fastfunc__all";
}

{
    my $input = <<'EOF';
    my ($bel, $f, $xs) = @_;

    my ($x, $p);
    ITERATE_FORWARD_OF($x, $p, $xs, sub {
        IF(CALL($f, $x), sub {
            return $p;
        });
    });

    return NIL;
EOF

    my $expected_output = <<'EOF';
    my ($bel, $f, $xs) = @_;

    while (!is_nil($xs)) {
        if (!is_nil($bel->call($f, $bel->car($xs)))) {
            return $xs;
        }
        $xs = $bel->cdr($xs);
    }

    return SYMBOL_NIL;
EOF

    my $actual_output = expand($input);

    is $actual_output, $expected_output, "expansion of fastfunc__some";
}

