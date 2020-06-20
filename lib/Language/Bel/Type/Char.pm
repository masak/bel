package Language::Bel::Type::Char;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $codepoint) = @_;

    my $obj = { codepoint => $codepoint };
    return bless($obj, $class);
}

1;
