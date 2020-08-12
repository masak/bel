package Language::Bel::Type::Stream;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $handle, $mode) = @_;

    my $obj = { handle => $handle, mode => $mode };
    return bless($obj, $class);
}

sub write_char {
    my ($self, $chr) = @_;

    print {$self->{handle}} $chr;
}

1;
