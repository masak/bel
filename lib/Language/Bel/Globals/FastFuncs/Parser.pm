package Language::Bel::Globals::FastFuncs::Parser;

use 5.006;
use strict;
use warnings;

use Language::Bel::Globals::FastFuncs::Lexer qw(
    tokenize
);

use Exporter 'import';

sub parse {
    my ($input) = @_;

    my @tokens = tokenize($input);

    my $parser = bless(
        { tokens => [@tokens] },
        __PACKAGE__,
    );

    return $parser->parse_statement_list();
}

sub token_count {
    my ($self) = @_;

    return scalar(@{ $self->{tokens} });
}

sub there_are_tokens_left {
    my ($self) = @_;

    return $self->token_count() > 0;
}

sub peek_token {
    my ($self) = @_;

    die "Tried to peek into empty token stream"
        unless $self->there_are_tokens_left();

    return $self->{tokens}->[0];
}

sub peek_token_of_type {
    my ($self, $type) = @_;

    my $token = $self->peek_token();

    return $token->{type} eq $type;
}

sub consume_token {
    my ($self) = @_;

    die "Tried to consume empty token stream"
        unless $self->there_are_tokens_left();

    return shift(@{ $self->{tokens} });
}

sub expect_token_of_type {
    my ($self, $type) = @_;

    die "Expected token type '$type', found end of token stream"
        unless $self->there_are_tokens_left();

    my $token = $self->peek_token();
    my $actual_type = $token->{type};

    die "Expected token type '$type', found type '$actual_type'"
        unless $type eq $actual_type;

    return;
}

sub consume_token_of_type {
    my ($self, $type) = @_;

    $self->expect_token_of_type($type);
    return $self->consume_token();
}

sub parse_statement_list {
    my ($self) = @_;

    my @children;
    my $ast = {
        type => "statement_list",
        children => \@children,
    };

    while ($self->there_are_tokens_left()
        && !$self->peek_token_of_type("closing_brace")) {
        push @children, $self->parse_statement();
    }

    return $ast;
}

sub pretty {
    my ($token) = @_;

    my $kvs = join(", ", map {
        $_ . " => " . $token->{$_}
    } keys(%{ $token }));
    return "{ $kvs }";
}

sub parse_statement {
    my ($self) = @_;

    # is only called after we confirmed that there are tokens left,
    # so we're entitled to call peek_token()

    my $type;
    my $child;

    my $token = $self->peek_token();
    if ($token->{type} eq "return") {
        $type = "return_statement";
        $self->consume_token();
        $child = $self->parse_expression();
    }
    elsif ($token->{type} eq "my") {
        $type = "my_statement";
        $child = $self->parse_my();
    }
    elsif ($token->{type} eq "bareword") {
        $type = "expr_statement";
        $child = $self->parse_expression();
    }
    else {
        die "Unrecognized token in statement: ", pretty($token);
    }

    $self->consume_token_of_type("semicolon");

    return {
        type => $type,
        children => [$child],
    };
}

sub is_stopper {
    my ($token) = @_;

    return $token->{type} =~ /^(?:semicolon|closing_paren|comma)$/;
}

sub parse_expression {
    my ($self) = @_;

    die "Expected expression"
        unless $self->there_are_tokens_left();

    my @term_stack;
    my @op_stack;

    my $SHIFT = sub {
        my ($term) = @_;

        push @term_stack, $term;
    };

    my $REDUCE = sub {
        die "Not enough terms on the term stack"
            unless @term_stack >= 2;
        die "No operator on the op stack"
            unless @op_stack;

        # note the reverse order; last in, first out
        my $term2 = pop @term_stack;
        my $term1 = pop @term_stack;

        my $op = pop @op_stack;

        push @term_stack, {
            type => $op->{type},
            children => [$term1, $term2],
        };
    };

    my $expect_mode = "term";
    my $token;
    while (!is_stopper($token = $self->peek_token())) {
        my $token_count_at_beginning = $self->token_count();

        if ($expect_mode eq "term") {
            if ($token->{type} =~ /^(?:bareword|variable)$/) {
                $SHIFT->($self->consume_token());
                $expect_mode = "op";
            }
            elsif ($token->{type} eq "my") {
                $SHIFT->($self->parse_my());
                $expect_mode = "op";
            }
            elsif ($token->{type} eq "sub") {
                $SHIFT->($self->parse_sub());
                $expect_mode = "op";
            }
            else {
                die "Unrecognized token in term position: ", pretty($token);
            }
        }
        else { # expecting an op(erator)
            if ($token->{type} eq "opening_paren") {
                $self->consume_token();
                my $argument_list = $self->parse_argument_list();
                $self->consume_token_of_type("closing_paren");

                my $term = pop @term_stack;
                $SHIFT->({
                    type => "call",
                    children => [$term, $argument_list],
                });

                # function call parens are a postcircumfix; so we're still
                # expecting an op after it
                $expect_mode = "op";
            }
            elsif ($token->{type} =~ /^(?:colon|qmark)$/) {
                push @op_stack, $self->consume_token();

                $expect_mode = "term";
            }
            else {
                die "Unrecognized token in operator position: ",
                    pretty($token);
            }
        }

        die "Didn't consume any tokens; stuck at ", pretty($token)
            unless $self->token_count() < $token_count_at_beginning;
    }

    die "Expected term after ", $op_stack[-1]->{type},
        "; found ", $token->{type}
        if $expect_mode eq "term";

    die "There are no terms left on stack"
        unless @term_stack;

    while (@op_stack) {
        $REDUCE->();
    }

    return $term_stack[-1];
}

sub parse_argument_list {
    my ($self) = @_;

    my @children;

    unless ($self->peek_token_of_type("closing_paren")) {
        push @children, $self->parse_expression();

        while ($self->peek_token_of_type("comma")) {
            $self->consume_token();
            push @children, $self->parse_expression();
        }

        $self->expect_token_of_type("closing_paren");
    }

    return {
        type => "argument_list",
        children => \@children,
    };
}

sub parse_my {
    my ($self) = @_;

    $self->consume_token_of_type("my");

    my @children;
    if ($self->peek_token_of_type("variable")) {
        push @children, $self->consume_token();
    }
    elsif ($self->peek_token_of_type("opening_paren")) {
        $self->consume_token();

        push @children, $self->parse_variable_list();

        $self->consume_token_of_type("closing_paren");
    }
    else {
        die "Expected variable or opening_paren, found ",
            pretty($self->peek_token());
    }

    if ($self->peek_token_of_type("assign")) {
        $self->consume_token();
        push @children, $self->parse_expression();
    }

    return {
        type => "my",
        children => \@children,
    };
}

sub parse_variable_list {
    my ($self) = @_;

    my @children;

    unless ($self->peek_token_of_type("closing_paren")) {
        push @children, $self->consume_token_of_type("variable");

        while ($self->peek_token_of_type("comma")) {
            $self->consume_token();
            push @children, $self->consume_token_of_type("variable");
        }

        $self->expect_token_of_type("closing_paren");
    }

    return {
        type => "variable_list",
        children => \@children,
    };
}

sub parse_sub {
    my ($self) = @_;

    $self->consume_token_of_type("sub");
    $self->consume_token_of_type("opening_brace");

    my @children;
    push @children, $self->parse_statement_list();

    $self->consume_token_of_type("closing_brace");

    return {
        type => "sub",
        children => \@children,
    };
}

our @EXPORT_OK = qw(
    parse
);

1;
