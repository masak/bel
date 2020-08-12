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

sub stat {
    my ($self) = @_;

    return $self->{mode};
}

sub close {
    my ($self) = @_;

    die "'already-closed\n"
        if $self->{mode}{name} eq "closed";

    close($self->{handle})
        or die $!;
    $self->{mode} = bless(
        { name => "closed" },
        "Language::Bel::Type::Symbol",
    );
}

1;
