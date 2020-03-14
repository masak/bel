package Language::Bel::Type::Pair::FastFunc;
use base qw(Language::Bel::Type::Pair);

sub new {
    my ($class, $pair, $fn) = @_;

    my $obj = { car => $pair->{car}, cdr => $pair->{cdr}, fn => $fn };
    return bless($obj, $class);
}

sub apply {
    my ($self, $interpreter, @args) = @_;

    return $self->{fn}->($interpreter, @args);
}

1;
