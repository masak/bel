package Language::Bel::LazyGlobal;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $ast) = @_;

    my $obj = { ast => $ast };
    return bless($obj, $class);
}

sub ast {
    my ($self) = @_;

    return $self->{ast};
}

1;
