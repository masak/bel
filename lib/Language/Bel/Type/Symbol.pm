package Language::Bel::Type::Symbol;

sub new {
    my ($class, $name) = @_;

    my $obj = { name => $name };
    return bless($obj, $class);
}

1;
