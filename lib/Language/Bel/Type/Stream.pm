package Language::Bel::Type::Stream;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $path_str, $mode) = @_;

    my $handle;
    if ($mode eq "out") {
        open($handle, ">", $path_str)
            or die "'ioerror\n";
    }
    else {
        open($handle, "<", $path_str)
            or $! =~ /No such file/ and die "'notexist\n"
            or die "'ioerror\n";
    }

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
        unless $self->{mode} eq "out";

    print {$self->{handle}} $chr;
}

sub stat {
    my ($self) = @_;

    return $self->{mode};
}

sub close {
    my ($self) = @_;

    die "'already-closed\n"
        if $self->{mode} eq "closed";

    close($self->{handle})
        or die $!;
    $self->{mode} = "closed";
}

sub mode {
    my ($self) = @_;

    return $self->{mode};
}

1;
