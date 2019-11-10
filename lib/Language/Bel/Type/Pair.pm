package Language::Bel::Type::Pair;

sub new {
    my ($class, $car, $cdr) = @_;

    my $obj = { car => $car, cdr => $cdr };
    return bless($obj, $class);
}

1;
