package Language::Bel::Globals::FastFuncs::Preprocessor;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub preprocess {
    open my $SOURCE, "<", "lib/Language/Bel/Globals/FastFuncs/Source.pm"
        or die "Couldn't open source file: $!";

    my @lines;
    while (my $line = <$SOURCE>) {
        $line =~ s/\r?\n$//;
        push @lines, $line;
    }

    close $SOURCE;

    check_function_names_mangled(@lines);
    @lines = nanopass_demangle_function_names(@lines);

    return join("", map { "$_\n" } @lines);
}

sub check_function_names_mangled {
    my (@input) = @_;

    for my $line (@input) {
        if ($line =~ /^\s+"([^"]+)" => sub \{$/) {
            my $name = $1;
            if ($name !~ /^\w+$/) {
                die "Sub of name '$name' is not mangled";
            }
        }
    }
}

sub nanopass_demangle_function_names {
    my (@input) = @_;

    my @output;
    for my $line (@input) {
        if ($line =~ /^(\s+)"([^"]+)" => sub \{$/) {
            my $indent = $1;
            my $mangled_name = $2;
            $mangled_name =~ s/__eq/=/g;
            $mangled_name =~ s/__hat/^/g;
            $mangled_name =~ s/__lt/</g;
            $mangled_name =~ s/__minus/-/g;
            $mangled_name =~ s/__plus/+/g;
            $mangled_name =~ s!__slash!/!g;
            $mangled_name =~ s/__star/*/g;
            push @output, qq[$indent"$mangled_name" => sub {];
        }
        else {
            push @output, $line;
        }
    }

    return @output;
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
