#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Digest::MD5 qw(md5_hex);

use Language::Bel::Test qw(
    slurp_file
);

use Language::Bel::Globals::Generator qw(generate_globals);

binmode STDOUT, ':encoding(utf-8)';

plan tests => 1;

{
    my $actual_globals = slurp_file("lib/Language/Bel/Globals.pm");

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
