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

    check_no_fastfuncs_decl(@lines);
    @lines = nanopass_turn_subs_into_fastfuncs_decl(@lines);

    check_no_exporter_stuff(@lines);
    @lines = nanopass_add_exporter_stuff(@lines);

    check_function_names_mangled(@lines);
    @lines = nanopass_demangle_function_names(@lines);

    return join("", map { "$_\n" } @lines);
}

sub check_no_fastfuncs_decl {
    my (@input) = @_;

    for my $line (@input) {
        if ($line eq "my \%FASTFUNCS = (") {
            die "This line should not be in source: `$line`";
        }
    }
}

sub nanopass_turn_subs_into_fastfuncs_decl {
    my (@input) = @_;

    my $indented_mode = 0;
    my @output;
    for my $line (@input) {
        if (!$indented_mode && $line =~ /^sub /) {
            $indented_mode = 1;
            push @output, "my \%FASTFUNCS = (";
        }

        if ($line =~ /^sub (\w+) \{/) {
            $line = qq["$1" => sub {];
        }
        elsif ($line eq "}") {
            $line = "},";
        }

        if ($line eq "1;") {
            $indented_mode = 0;

            my $empty_line = pop @output;
            push @output, ");";
            push @output, $empty_line;
        }

        if ($indented_mode && $line) {
            $line = (" " x 4) . $line;
        }

        push @output, $line;
    }

    return @output;
}

sub check_no_exporter_stuff {
    my (@input) = @_;

    for my $line (@input) {
        if ($line =~ /^(?:use Exporter|sub FASTFUNCS|our \@EXPORT_OK)/) {
            die "This line should not be in source: `$line`";
        }
    }
}

sub nanopass_add_exporter_stuff {
    my (@input) = @_;

    my @output;
    for my $line (@input) {
        if ($line =~ /^my \%FASTFUNCS = \($/) {
            push @output,
                "use Exporter 'import';",
                "";
        }
        elsif ($line eq "1;") {
            push @output,
                "sub FASTFUNCS {",
                "    return \\%FASTFUNCS;",
                "}",
                "",
                "our \@EXPORT_OK = qw(",
                "    FASTFUNCS",
                ");",
                "";
        }
        push @output, $line;
    }

    return @output;
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
