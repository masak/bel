package Language::Bel::Globals::FastFuncs::Visitor;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub visit {
    my ($node, $ancestors_ref, $rules_ref) = @_;

    if (!defined($ancestors_ref)) {
        $ancestors_ref = [];
    }
    if (!defined($rules_ref)) {
        $rules_ref = {};
    }

    # Perform a postorder traversal of the AST.

    my $type = $node->{type};

    if ($type eq "expr_statement"
        && $node->{children}[0]{type} eq "call"
        && $node->{children}[0]{children}[0]{type} eq "bareword") {
        my $name = $node->{children}[0]{children}[0]{name};
        if ($name eq "ITERATE_FORWARD") {
            my ($elem_var, $list_var, $sub)
                = @{ $node->{children}[0]{children}[1]{children} };

            # $xs = $bel->cdr($xs);
            # {{{variable}}} = $bel->cdr({{{variable}}};
            #    $list_var                  $list_var
            my $statement_list = {
                type => "statement_list",
                children => [
                    @{ $sub->{children}[0]{children} },
                    {
                        type => "expr_statement",
                        children => [
                            {
                                type => "assign",
                                children => [
                                    $list_var,
                                    {
                                        type => "method_call",
                                        children => [
                                            {
                                                type => "variable",
                                                name => q[$bel],
                                            },
                                            {
                                                type => "bareword",
                                                name => q[cdr],
                                            },
                                            {
                                                type => "argument_list",
                                                children => [$list_var],
                                            },
                                        ],
                                    },
                                ],
                            },
                        ],
                    },
                ],
            };

            %{ $node } = (
                type => "while_statement",
                children => [
                    {
                        type => "not",
                        children => [
                            {
                                type => "call",
                                children => [
                                    {
                                        type => "bareword",
                                        name => "is_nil",
                                    },
                                    {
                                        type => "argument_list",
                                        children => [$list_var],
                                    },
                                ],
                            },
                        ],
                    },
                    $statement_list,
                ],
            );

            if (scalar(@{ $ancestors_ref }) > 0) {
                my $statement_list = $ancestors_ref->[-1];
                my @statements = @{ $statement_list->{children} };
                my $i = 0;

                my $prev_sibling;
                SIBLING:
                for my $curr_sibling (@statements) {
                    if ($curr_sibling == $node) {
                        if (defined($prev_sibling)
                            && $prev_sibling->{type} eq "my_statement"
                            && $prev_sibling->{children}[0]{children}[0]{type}
                                eq "variable"
                            && $prev_sibling->{children}[0]{children}[0]{name}
                                eq $elem_var->{name}) {
                            splice(@{ $statement_list->{children} }, $i-1, 1);
                        }

                        last SIBLING;
                    }

                    $prev_sibling = $curr_sibling;
                    $i++;
                }
            }

            $rules_ref->{$node} = sub {
                my ($descendant_node) = @_;

                if ($descendant_node->{type} eq "variable"
                    && $descendant_node->{name} eq $elem_var->{name}) {
                    %{ $descendant_node } = (
                        type => "method_call",
                        children => [
                            {
                                type => "variable",
                                name => q[$bel],
                            },
                            {
                                type => "bareword",
                                name => q[car],
                            },
                            {
                                type => "argument_list",
                                children => [$list_var],
                            },
                        ],
                    );
                }
            };
        }
        elsif ($name eq "ITERATE_FORWARD_OF") {
            my ($elem_var, $pair_var, $list_var, $sub)
                = @{ $node->{children}[0]{children}[1]{children} };

            # $xs = $bel->cdr($xs);
            # {{{variable}}} = $bel->cdr({{{variable}}};
            #    $list_var                  $list_var
            my $statement_list = {
                type => "statement_list",
                children => [
                    @{ $sub->{children}[0]{children} },
                    {
                        type => "expr_statement",
                        children => [
                            {
                                type => "assign",
                                children => [
                                    $list_var,
                                    {
                                        type => "method_call",
                                        children => [
                                            {
                                                type => "variable",
                                                name => q[$bel],
                                            },
                                            {
                                                type => "bareword",
                                                name => q[cdr],
                                            },
                                            {
                                                type => "argument_list",
                                                children => [$list_var],
                                            },
                                        ],
                                    },
                                ],
                            },
                        ],
                    },
                ],
            };

            %{ $node } = (
                type => "while_statement",
                children => [
                    {
                        type => "not",
                        children => [
                            {
                                type => "call",
                                children => [
                                    {
                                        type => "bareword",
                                        name => "is_nil",
                                    },
                                    {
                                        type => "argument_list",
                                        children => [$list_var],
                                    },
                                ],
                            },
                        ],
                    },
                    $statement_list,
                ],
            );

            if (scalar(@{ $ancestors_ref }) > 0) {
                my $statement_list = $ancestors_ref->[-1];
                my @statements = @{ $statement_list->{children} };
                my $i = 0;

                my $prev_sibling;
                SIBLING:
                for my $curr_sibling (@statements) {
                    if ($curr_sibling == $node) {
                        if (defined($prev_sibling)
                            && $prev_sibling->{type} eq "my_statement"
                            && $prev_sibling->{children}[0]{children}[0]{type}
                                eq "variable"
                            && $prev_sibling->{children}[0]{children}[0]{name}
                                eq $elem_var->{name}) {
                            splice(@{ $statement_list->{children} }, $i-1, 1);
                        }
                        elsif (defined($prev_sibling)
                            && $prev_sibling->{type} eq "my_statement"
                            && $prev_sibling->{children}[0]{children}[0]{type}
                                eq "variable_list"
                            && 0 == grep {
                                $_->{name} ne $elem_var->{name}
                                && $_->{name} ne $pair_var->{name} }
                                @{ $prev_sibling->{children}[0]{children}[0]{children} }) {
                            splice(@{ $statement_list->{children} }, $i-1, 1);
                        }

                        last SIBLING;
                    }

                    $prev_sibling = $curr_sibling;
                    $i++;
                }
            }

            $rules_ref->{$node} = sub {
                my ($descendant_node) = @_;

                if ($descendant_node->{type} eq "variable"
                    && $descendant_node->{name} eq $pair_var->{name}) {
                    %{ $descendant_node } = (
                        type => "variable",
                        name => $list_var->{name},
                    );
                }
                elsif ($descendant_node->{type} eq "variable"
                    && $descendant_node->{name} eq $elem_var->{name}) {
                    %{ $descendant_node } = (
                        type => "method_call",
                        children => [
                            {
                                type => "variable",
                                name => q[$bel],
                            },
                            {
                                type => "variable",
                                name => q[car],
                            },
                            {
                                type => "argument_list",
                                children => [$list_var],
                            },
                        ],
                    );
                }
            };
        }
        elsif ($name eq "IF") {
            my ($condition, $sub)
                = @{ $node->{children}[0]{children}[1]{children} };

            %{ $node } = (
                type => "if_statement",
                children => [
                    {
                        type => "not",
                        children => [
                            {
                                type => "call",
                                children => [
                                    {
                                        type => "bareword",
                                        name => "is_nil",
                                    },
                                    {
                                        type => "argument_list",
                                        children => [$condition],
                                    },
                                ],
                            },
                        ],
                    },
                    $sub->{children}[0],
                ],
            );
        }
        elsif ($name eq "UNLESS") {
            my ($condition, $sub)
                = @{ $node->{children}[0]{children}[1]{children} };

            %{ $node } = (
                type => "if_statement",
                children => [
                    {
                        type => "call",
                        children => [
                            {
                                type => "bareword",
                                name => "is_nil",
                            },
                            {
                                type => "argument_list",
                                children => [$condition],
                            },
                        ],
                    },
                    $sub->{children}[0],
                ],
            );
        }
        else {
            # we let it through on this level; catch any unknown macro
            # calls on the next lower level
        }
    }
    elsif ($type eq "call" && $node->{children}[0]{type} eq "bareword") {
        my $name = $node->{children}[0]{name};
        if ($name eq "CALL") {
            my ($fn, @args) = @{ $node->{children}[1]{children} };

            # $bel->call($f, $bel->car($xs))
            %{ $node } = (
                type => "method_call",
                children => [
                    {
                        type => "variable",
                        name => q[$bel],
                    },
                    {
                        type => "bareword",
                        name => q[call],
                    },
                    {
                        type => "argument_list",
                        children => [
                            $fn,
                            @args,
                        ],
                    },
                ],
            );
        }
        elsif ($name =~ /^[a-z_]+$/) {
            # Not a macro call, so we just let it through
        }
        else {
            die "Don't know how to handle macro call ", $name, "()";
        }
    }
    elsif ($type eq "bareword") {
        my $name = $node->{name};
        if ($name eq "NIL") {
            $node->{name} = "SYMBOL_NIL";
        }
        elsif ($name eq "T") {
            $node->{name} = "SYMBOL_T";
        }
        elsif ($name =~ /^[a-z_]+$/) {
            # Not a macro, so we just let it through
        }
        else {
            die "Don't know how to handle bareword ", $name;
        }
    }
    elsif ($type eq "variable") {
    }

    # apply the rules, innermost first
    for my $ancestor (reverse(@{ $ancestors_ref })) {
        if (exists $rules_ref->{$ancestor}) {
            $rules_ref->{$ancestor}->($node);
        }
    }

    my @children = exists $node->{children}
        ? @{ $node->{children} }
        : ();

    push @{ $ancestors_ref }, $node;
    for my $child (@children) {
        $child = visit($child, $ancestors_ref, $rules_ref);
    }
    pop @{ $ancestors_ref };

    return $node;
}

our @EXPORT_OK = qw(
    visit
);

1;
