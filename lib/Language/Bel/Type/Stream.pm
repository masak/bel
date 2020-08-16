package Language::Bel::Type::Stream;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $handle, $mode) = @_;

    my $obj = { handle => $handle, mode => $mode };
    return bless($obj, $class);
}

sub read_char {
    my ($self) = @_;

    read($self->{handle}, my $chr, 1);
    return $chr;
}

sub write_char {
    my ($self, $chr) = @_;

    die "'badmode\n"
        unless $self->{mode}{name} eq "out";

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

sub mode {
    my ($self) = @_;

    return $self->{mode}{name};
}

1;
