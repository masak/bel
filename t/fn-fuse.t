#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel;

plan tests => 5;

sub is_bel_output {
    my ($expr, $expected_output) = @_;

    my $actual_output = "";
    my $b = Language::Bel->new({ output => sub {
        my ($string) = @_;
        $actual_output = "$actual_output$string";
    } });
    $b->eval($expr);

    is($actual_output, $expected_output, "$expr ==> $expected_output");
}

sub is_bel_error {
    my ($expr, $expected_error) = @_;

    my $b = Language::Bel->new({ output => undef });
    eval {
        $b->eval($expr);
    };

    my $actual_error = $@;
    $actual_error =~ s/\n$//;
    is($actual_error, $expected_error, "$expr ==> ERROR[$expected_error]");
}

{
    is_bel_output("(fuse idfn '((a b) (c d) (e f)))", "(a b c d e f)");
    is_bel_output("(fuse list '(a b c) '(1 2 3))", "(a 1 b 2 c 3)");
    is_bel_output("(fuse list '(a b c) '(1 2))", "(a 1 b 2)");
    is_bel_output("(fuse join)", "nil");
    is_bel_error("(fuse car '(a b c) '(1 2 3))", "car-on-atom");
}
