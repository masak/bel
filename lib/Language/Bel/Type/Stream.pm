package Language::Bel::Type::Stream;

use 5.006;
use strict;
use warnings;

sub new {
    my ($class, $path_str, $mode) = @_;

    my $obj = { path_str => $path_str, mode => $mode };
    return bless($obj, $class);
}

1;
