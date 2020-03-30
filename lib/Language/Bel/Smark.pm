package Language::Bel::Smark;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

sub new {
    my ($class, $type, $value) = @_;

    my $obj = { type => $type, value => $value };
    return bless($obj, $class);
}

sub value {
    my ($self) = @_;

    return $self->{value};
}

sub is_smark {
    my ($value) = @_;

    return ref($value) eq "Language::Bel::Smark";
}

sub is_smark_of_type {
    my ($value, $type) = @_;

    return is_smark($value) && $value->{type} eq $type;
}

sub make_smark_of_type {
    my ($type, $value) = @_;

    return Language::Bel::Smark->new($type, $value);
}

our @EXPORT_OK = qw(
    is_smark
    is_smark_of_type
    make_smark_of_type
);

1;
