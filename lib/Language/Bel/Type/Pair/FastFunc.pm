package Language::Bel::Type::Pair::FastFunc;
use base qw(Language::Bel::Type::Pair);

sub new {
    my ($class, $pair, $fn) = @_;

    my $obj = { car => $pair->{car}, cdr => $pair->{cdr}, fn => $fn };
    return bless($obj, $class);
}

1;
