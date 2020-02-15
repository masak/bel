package Language::Bel::LazyGlobal;

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
