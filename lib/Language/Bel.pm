package Language::Bel;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    is_char
    is_pair
    is_symbol
    make_char
    make_pair
    make_symbol
    pair_car
    pair_cdr
    symbol_name
);
use Language::Bel::Symbols::Common qw(
    SYMBOL_NIL
    SYMBOL_QUOTE
    SYMBOL_T
);
use Language::Bel::Primitives qw(
    prim_car
    prim_cdr
    prim_id
    prim_join
    prim_type
    PRIMITIVES
);

=head1 NAME

Language::Bel - An interpreter for Paul Graham's language Bel

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Language::Bel;

    my $foo = Language::Bel->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
    my ($class, $options_ref) = @_;
    my $self = {
        ref($options_ref) eq "HASH" ? %$options_ref : (),
    };

    return bless($self, $class);
}

=head2 eval

=cut

sub eval {
    my ($self, $expr) = @_;

    my $ast = $self->read($expr)->{ast};
    my $result = $self->eval_ast($ast);
    my $result_string = $self->ast_to_string($result);

    my $output = $self->{output};
    if (ref($output) eq "CODE") {
        $output->($result_string);
    }

    return;
}

sub read {
    my ($self, $expr, $pos) = @_;

    $pos = defined($pos) ? $pos : 0;

    my $skip_whitespace = sub {
        while ($pos < length($expr) && substr($expr, $pos, 1) =~ /\s/) {
            ++$pos;
        }
    };

    $skip_whitespace->();
    my $c = substr($expr, $pos, 1);
    if ($c eq "(") {
        ++$pos;
        my @list;
        my $seen_dot = "";
        my $seen_element_after_dot = "";
        while ($pos < length($expr)) {
            $skip_whitespace->();
            my $cc = substr($expr, $pos, 1);
            if ($cc eq ")") {
                ++$pos;
                last;
            }
            elsif ($cc eq ".") {
                ++$pos;
                $seen_dot = 1;
            }

            if ($seen_element_after_dot) {
                die "only one element after dot allowed";
            }
            my $r = $self->read($expr, $pos);
            if ($seen_dot) {
                $seen_element_after_dot = 1;
            }
            push @list, $r->{ast};
            $pos = $r->{pos};
        }
        my $ast = $seen_dot ? pop(@list) : SYMBOL_NIL;
        for my $e (reverse(@list)) {
            $ast = make_pair($e, $ast);
        }
        return { ast => $ast, pos => $pos };
    }
    elsif ($c eq "'") {
        ++$pos;
        my $r = $self->read($expr, $pos);
        my $ast = make_pair(SYMBOL_QUOTE, make_pair($r->{ast}, SYMBOL_NIL));
        return { ast => $ast, pos => $r->{pos} };
    }
    elsif ($c eq "\\") {
        ++$pos;
        my $start = $pos;
        EAT_CHAR:
        {
            do {
                my $cc = substr($expr, $pos, 1);
                # XXX: cheat for now
                last EAT_CHAR if $cc eq ")" or $cc =~ /\s/;
                ++$pos;
            } while ($pos < length($expr));
        }
        my $ast = make_char(substr($expr, $start, $pos - $start));
        return { ast => $ast, pos => $pos };
    }
    else {  # symbol
        my $start = $pos;
        EAT_CHAR:
        {
            do {
                my $cc = substr($expr, $pos, 1);
                # XXX: cheat for now
                last EAT_CHAR if $cc eq ")" or $cc =~ /\s/;
                ++$pos;
            } while ($pos < length($expr));
        }
        my $ast = make_symbol(substr($expr, $start, $pos - $start));
        return { ast => $ast, pos => $pos };
    }
}

sub eval_ast {
    my ($self, $ast) = @_;

    if (is_pair($ast)) {
        my $head = pair_car($ast);
        my $rest = pair_cdr($ast);
        if (is_symbol($head)) {
            my $name = symbol_name($head);
            if ($name eq "id") {
                my $first_arg = $self->eval_ast(prim_car($rest));
                my $second_arg = $self->eval_ast(prim_car(prim_cdr($rest)));
                return prim_id($first_arg, $second_arg);
            }
            elsif ($name eq "join") {
                my $first_arg = $self->eval_ast(prim_car($rest));
                my $second_arg = $self->eval_ast(prim_car(prim_cdr($rest)));
                return prim_join($first_arg, $second_arg);
            }
            elsif ($name eq "car") {
                my $arg = $self->eval_ast(prim_car($rest));
                return prim_car($arg);
            }
            elsif ($name eq "cdr") {
                my $arg = $self->eval_ast(prim_car($rest));
                return prim_cdr($arg);
            }
            elsif ($name eq "type") {
                my $arg = $self->eval_ast(prim_car($rest));
                return prim_type($arg);
            }
            elsif ($name eq "quote") {
                my $first_arg = pair_car($rest);
                return $first_arg;
            }
            elsif ($name eq "lit") {
                return $ast;
            }
            else {
                die "unhandled: unknown thing `$name` as head";
            }
        }
        else {
            die "unhandled: not a symbol as head";
        }
    }
    elsif (is_symbol($ast)) {
        my $name = symbol_name($ast);
        if ($name eq "t" || $name eq "nil") {
            return $ast;
        }
        if (exists PRIMITIVES->{$name}) {
            return PRIMITIVES->{$name};
        }
        die "unhandled: variable lookup of `$name`";
    }
    elsif (is_char($ast)) {
        return $ast;
    }
    else {
        die "unhandled: not a pair";
    }
}

sub ast_to_string {
    my ($self, $ast) = @_;

    if (is_symbol($ast)) {
        my $name = symbol_name($ast);
        return $name;
    }
    elsif (is_pair($ast)) {
        my @fragments = ("(");
        my $first_elem = 1;
        while (is_pair($ast)) {
            if (!$first_elem) {
                push @fragments, " ";
            }
            push @fragments, $self->ast_to_string(pair_car($ast));
            $ast = pair_cdr($ast);
            $first_elem = "";
        }
        if (!is_symbol($ast) || symbol_name($ast) ne "nil") {
            push @fragments, " . ";
            push @fragments, $self->ast_to_string($ast);
        }
        push @fragments, ")";
        return join("", @fragments);
    }
    else {
        die "unhandled: not a symbol";
    }
}

=head1 AUTHOR

Carl Mäsak, C<< <carl at masak.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-language-bel at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Language-Bel>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Language::Bel


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Language-Bel>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Language-Bel>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Language-Bel>

=item * Search CPAN

L<https://metacpan.org/release/Language-Bel>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2019 by Carl Mäsak.

This program is released under the following license:

  gpl_3


=cut

1; # End of Language::Bel
