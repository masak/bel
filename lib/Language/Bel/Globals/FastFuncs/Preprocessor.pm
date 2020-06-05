package Language::Bel::Globals::FastFuncs::Preprocessor;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub preprocess {
    open my $SOURCE, "<", "lib/Language/Bel/Globals/FastFuncs/Source.pm"
        or die "Couldn't open source file: $!";

    my @result;
    while (my $line = <$SOURCE>) {
        push @result, $line;
    }

    close $SOURCE;

    return join("", @result);
}

sub generate_target_file {
    open my $TARGET, ">", "lib/Language/Bel/Globals/FastFuncs.pm"
        or die "Couldn't open target file: $!";

    print {$TARGET} preprocess();

    close $TARGET;
}

our @EXPORT_OK = qw(
    generate_target_file
    preprocess
);

1;
