package Language::Bel::Globals::FastFuncs::Deparser;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub deparse {
    my ($ast) = @_;

    my $type = $ast->{type};
    my @children = exists $ast->{children}
        ? @{ $ast->{children} }
        : ();

    if ($type eq "statement_list") {
        my $i = 0;

        return join("", map {
            my $indent = " " x 4;
            my $newline = "\n";
            my $statement = deparse($_);

            my $indented = join("\n", map {
                "$indent$_"
            } split(/\n/, $statement));

            $i++ == 0 && $_->{type} eq "my_statement"
                ? "$indented$newline$newline"
                : $i == @children && $i > 2 && $_->{type} eq "return_statement"
                    ? "$newline$indented$newline"
                    : "$indented$newline";
        } @children);
    }
    elsif ($type eq "return_statement") {
        return "return " . deparse($children[0]) . ";";
    }
    elsif ($type eq "my_statement") {
        return deparse($children[0]) . ";";
    }
    elsif ($type eq "expr_statement") {
        return deparse($children[0]) . ";";
    }
    elsif ($type eq "while_statement") {
        my $condition = deparse($children[0]);
        my $statement_list = deparse($children[1]);
        return "while ($condition) {\n$statement_list}";
    }
    elsif ($type eq "if_statement") {
        my $condition = deparse($children[0]);
        my $statement_list = deparse($children[1]);
        return "if ($condition) {\n$statement_list}";
    }
    elsif ($type eq "my") {
        my $vars = deparse($children[0]);
        my $maybe_assignment = @children > 1
            ? " = " . deparse($children[1])
            : "";
        return "my $vars$maybe_assignment";
    }
    elsif ($type eq "variable_list") {
        my $variables = join(", ", map { deparse($_) } @children);
        return "($variables)";
    }
    elsif ($type eq "variable") {
        return $ast->{name};
    }
    elsif ($type eq "bareword") {
        return $ast->{name};
    }
    elsif ($type eq "qmark") {
        return deparse($children[0]) . " ? " . deparse($children[1]);
    }
    elsif ($type eq "colon") {
        return deparse($children[0]) . " : " . deparse($children[1]);
    }
    elsif ($type eq "assign") {
        return deparse($children[0]) . " = " . deparse($children[1]);
    }
    elsif ($type eq "call") {
        my $fn = deparse($children[0]);
        my $args = deparse($children[1]);
        return "$fn$args";
    }
    elsif ($type eq "argument_list") {
        my $arguments = join(", ", map { deparse($_) } @children);
        return "($arguments)";
    }
    elsif ($type eq "sub") {
        my $statement_list = deparse($children[0]);
        return "sub {\n$statement_list}";
    }
    elsif ($type eq "not") {
        my $expr = deparse($children[0]);
        return "!$expr";
    }
    else {
        die "Unknown AST type '$type'";
    }
}

our @EXPORT_OK = qw(
    deparse
);

1;
