#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

use Language::Bel::Test;

plan tests => 6;

is_bel_output("(do (each c (list \\0 \\0 \\1 \\0 \\0 \\0 \\0 \\1) (wrb c nil)) nil)", "!nil");
is_bel_output("(do (each c (list \\0 \\0 \\1 \\0 \\0 \\0 \\0 \\1) (wrb c nil)))", q[!"00100001"]);

sub bits {
    my ($char) = @_;

    my $ord = ord($char);

    my @bits;
    for my $b (128, 64, 32, 16, 8, 4, 2, 1) {
        push(@bits, $ord & $b ? "\\1" : "\\0");
    }

    return join(" ", @bits);
}

my $hello_bits = join(" ", map { bits($_) } split("", "hello"));
my $filename = "hellofile";

ok((!-e $filename), "`$filename` does not exist");
is_bel_output(
    qq[(let s (ops "$filename" 'out) (each c (list $hello_bits) (wrb c s)) nil)],
    "nil"
);
ok((-e $filename), "`$filename` now exists");

SKIP: {
    skip("opening '$filename' for reading", 1)
        unless -e $filename;

    open(my $HELLO, "<", $filename)
        or die "Could not open $filename for reading: $!";

    my $line = do { local $/; <$HELLO> };
    is $line, "hello", "the file has the expected contents";

    close($HELLO);
}

END {
    unlink($filename);
}
