package Language::Bel::Type::Char;

sub new {
    my ($class, $name) = @_;

    my $obj = { name => $name };
    return bless($obj, $class);
}

1;
