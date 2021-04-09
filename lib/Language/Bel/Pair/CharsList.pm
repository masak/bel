package Language::Bel::Pair::CharsList;
use base qw(Language::Bel::Pair);

use 5.006;
use strict;
use warnings;

use Language::Bel::Core qw(
    make_char
    make_pair
    SYMBOL_NIL
);

use Exporter 'import';

sub new {
    my ($class, $codepoint) = @_;

    my $obj = {
        codepoint => $codepoint,
    };
    return bless($obj, $class);
}

sub car {
    my ($self) = @_;

    my $codepoint = $self->{codepoint};

    my $bitrep = SYMBOL_NIL;
    for my $bit (reverse(split //, sprintf("%08b", $codepoint))) {
        $bitrep = make_pair(make_char(ord("0") + $bit), $bitrep);
    }

    return make_pair(
        make_char($codepoint),
        $bitrep,
    );
}

sub cdr {
    my ($self) = @_;

    my $codepoint = $self->{codepoint};

    if ($codepoint >= 127) {
        return SYMBOL_NIL;
    }

    return make_chars_list($codepoint + 1);
}

sub xar {
    my ($self, $car) = @_;

    die "Tried to modify an element of the `chars` list";
}

sub xdr {
    my ($self, $cdr) = @_;

    die "Tried to modify an element of the `chars` list";
}

sub codepoint {
    my ($self) = @_;

    return $self->{codepoint};
}

sub make_chars_list {
    my ($codepoint) = @_;

    return __PACKAGE__->new($codepoint);
}

our @EXPORT_OK = qw(
    make_chars_list
);

1;
