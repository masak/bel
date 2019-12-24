package Language::Bel::Logger;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

our $DEBUG = 1;
our $INFO = 2;
our $WARNING = 3;
our $ERROR = 4;
our $NONE = 5;

sub new {
    my ($class, $options_ref) = @_;
    my $self = {
        ref($options_ref) eq "HASH" ? %$options_ref : (),
    };

    if (!defined $self->{level}) {
        $self->{level} = $NONE;
    }

    return bless($self, $class);
}

my %level_mapping = (
    debug => $DEBUG,
    info => $INFO,
    warning => $WARNING,
    error => $ERROR,
);

sub level_of {
    my ($desc) = @_;

    my $m = $level_mapping{$desc};
    return $m || die "Unknown level description: $desc";
}

sub log {
    my ($self, $level_desc, $fn) = @_;

    my $level = level_of($level_desc);
    return unless $level >= $self->{level};

    my @message = $fn->();
    return unless @message;

    print(uc($level_desc), ": ", @message, "\n");
}

our @EXPORT_OK = qw(
    level_of
);

1;
