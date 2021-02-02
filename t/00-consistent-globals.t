#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Digest::MD5 qw(md5_hex);

use Language::Bel::Globals::Generator qw(generate_globals);

binmode STDOUT, ':encoding(utf-8)';

plan tests => 1;

{
    my $actual_globals;
    {
        open my $GLOBALS, "<", "lib/Language/Bel/Globals.pm"
            or die "Couldn't open globals module: $!";

        my @lines;
        while (my $line = <$GLOBALS>) {
            push @lines, $line;
        }

        close $GLOBALS;

        $actual_globals = join("", @lines);
        $actual_globals =~ s/\r//g;   # Windows likes these; we don't
    }

    my $bel = Language::Bel->new({ output => sub {} });

    my $generated_globals;
    do {
        local *STDOUT;
        open(STDOUT, ">>", \$generated_globals)
            or die "failed to open file handle to string ($!)\n";

        generate_globals($bel);     # will print into $generated_globals
    };

    is md5_hex($actual_globals),
        md5_hex($generated_globals),
        "the globals are up to date";
}
