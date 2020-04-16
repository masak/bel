package Language::Bel::Type::Pair::FastFunc;
use base qw(Language::Bel::Type::Pair);

sub new {
    my ($class, $pair, $fn, $where_fn) = @_;

    my $obj = {
        car => $pair->{car},
        cdr => $pair->{cdr},
        fn => $fn,
        where_fn => $where_fn,
    };
    return bless($obj, $class);
}

sub handles_where {
    my ($self) = @_;

    return ref($self->{where_fn}) eq "CODE";
}

sub apply {
    my ($self, $call, @args) = @_;

    return $self->{fn}->($call, @args);
}

sub where_apply {
    my ($self, $call, @args) = @_;

    return $self->{where_fn}->($call, @args);
}

1;
