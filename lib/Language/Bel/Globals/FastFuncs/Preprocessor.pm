package Language::Bel::Globals::FastFuncs::Preprocessor;

use 5.006;
use strict;
use warnings;

use Language::Bel::Globals::FastFuncs::Parser qw(
    parse
);
use Language::Bel::Globals::FastFuncs::Visitor qw(
    visit
);
use Language::Bel::Globals::FastFuncs::Deparser qw(
    deparse
);

use Exporter 'import';

sub expand {
    my ($input) = @_;

    return deparse(visit(parse($input)));
}

sub preprocess {
    open my $SOURCE, "<", "lib/Language/Bel/Globals/FastFuncs/Source.pm"
        or die "Couldn't open source file: $!";

    my @function_body_lines;
    my $reading_function_body = 0;
    my $seen_cutoff = 0;

    my @result;
    while (my $line = <$SOURCE>) {
        next
            if $line =~ /^use Language::Bel::Globals::FastFuncs::Macros;$/;

        $line =~ s{Language::Bel::Globals::FastFuncs::Source}
                  {Language::Bel::Globals::FastFuncs};

        $line =~ s/^ +$//;

        if ($line =~ /^sub (\w+)/) {
            push @result, $line;

            my $sub_name = $1;
            # right now we have a cutoff, so we don't have to parse/handle
            # all of the fastfuncs source before benefitting from some of
            # them -- this cutoff will move gradually downwards and
            # eventually disappear
            if ($sub_name eq "fastfunc__where__some") {
                $seen_cutoff = 1;
            }

            if (!$seen_cutoff) {
                $reading_function_body = 1;
                @function_body_lines = ();
            }
        }
        elsif ($reading_function_body) {
            if ($line =~ /^\}$/) {
                push @result, expand(join("", @function_body_lines));
                push @result, $line;

                $reading_function_body = 0;
            }
            else {
                push @function_body_lines, $line;
            }
        }
        else {
            push @result, $line;
        }
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
    expand
    generate_target_file
    preprocess
);

1;
