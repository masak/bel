package Language::Bel::Type::Char;

sub new {
    my ($class, $codepoint) = @_;

    my $obj = { codepoint => $codepoint };
    return bless($obj, $class);
}

1;
