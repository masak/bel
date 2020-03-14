package Language::Bel;

use 5.006;
use strict;
use warnings;

use Language::Bel::Types qw(
    char_name
    is_char
    is_nil
    is_pair
    is_string
    is_symbol
    make_char
    make_pair
    make_symbol
    pair_car
    pair_cdr
    string_value
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
    PRIM_FN
    PRIMITIVES
);
use Language::Bel::Reader qw(
    _read
);
use Language::Bel::Interpreter;
use Language::Bel::Printer qw(
    _print
);
use Language::Bel::Expander::Bquote qw(
    _bqexpand
);

=head1 NAME

Language::Bel - An interpreter for Paul Graham's language Bel

=head1 VERSION

Version 0.24

=cut

our $VERSION = '0.25';

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

    if (!defined $self->{interpreter}) {
        $self->{interpreter} = Language::Bel::Interpreter->new();
    }

    return bless($self, $class);
}

=head2 eval

Evaluates an expression, passed in as a string of Bel code.

=cut

sub eval {
    my ($self, $expr) = @_;

    my $ast = _bqexpand(_read($expr));
    my $result = $self->{interpreter}->eval_ast($ast);
    my $result_string = _print($result);

    my $output = $self->{output};
    if (ref($output) eq "CODE") {
        $output->($result_string);
    }

    return;
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
