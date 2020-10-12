package Language::Bel::Globals::FastFuncs::Preprocessor;

use 5.006;
use strict;
use warnings;

use Language::Bel::Globals::FastFuncs::Parser qw(
    parse
);
use Language::Bel::Globals::FastFuncs::Visitor qw(
    visit
    visit_where
);
use Language::Bel::Globals::FastFuncs::Deparser qw(
    deparse
);

use Exporter 'import';

sub expand {
    my ($input) = @_;

    return deparse(visit(parse($input)));
}

sub expand_where {
    my ($input) = @_;

    return deparse(visit_where(visit(parse($input))));
}

sub preprocess {
    open my $SOURCE, "<", "lib/Language/Bel/Globals/FastFuncs/Source.pm"
        or die "Couldn't open source file: $!";

    my @function_body_lines;
    my $reading_function_body = 0;
    my $seen_cutoff = 0;
    my $generate_where = 0;
    my $function_name;

    my @result;
    while (my $line = <$SOURCE>) {
        next
            if $line =~ /^use Language::Bel::Globals::FastFuncs::Macros;$/;

        $line =~ s{Language::Bel::Globals::FastFuncs::Source}
                  {Language::Bel::Globals::FastFuncs};

        $line =~ s/^ +$//;

        if ($line =~ /^\{\[\s*(\w+)\s*\]\}$/) {
            my $annotation = $1;
            if ($annotation eq "GENERATE_WHERE") {
                $generate_where = 1;
            }
            else {
                die "Unknown annotation: '$annotation'";
            }
            # and we don't emit the line into @result
        }
        elsif ($line =~ /^sub (\w+)/) {
            push @result, $line;

            $function_name = $1;
            # right now we have a cutoff, so we don't have to parse/handle
            # all of the fastfuncs source before benefitting from some of
            # them -- this cutoff will move gradually downwards and
            # eventually disappear
            if ($function_name eq "fastfunc__reduce") {
                $seen_cutoff = 1;
            }

            if (!$seen_cutoff) {
                $reading_function_body = 1;
                @function_body_lines = ();
            }
        }
        elsif ($reading_function_body) {
            if ($line =~ /^\}$/) {
                push @result,
                    expand(join("", @function_body_lines)),
                    $line;

                if ($generate_where) {
                    my $where_function_name = $function_name;
                    $where_function_name =~ s/fastfunc__/fastfunc__where__/;

                    push @result, "\n",
                        "sub $where_function_name {\n",
                        expand_where(join("", @function_body_lines)),
                        $line;
                }

                $reading_function_body = 0;
                $generate_where = 0;
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
    expand_where
    generate_target_file
    preprocess
);

1;
