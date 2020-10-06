package Language::Bel::Globals::FastFuncs::Lexer;

use 5.006;
use strict;
use warnings;

use Exporter 'import';

my %PUNCTUATION = (
    "(" => "opening_paren",
    ")" => "closing_paren",
    "," => "comma",
    ":" => "colon",
    ";" => "semicolon",
    "=" => "assign",
    "?" => "qmark",
    "{" => "opening_brace",
    "}" => "closing_brace",
);

sub tokenize {
    my ($input) = @_;

    my @tokens;
    my $pos = 0;

    my $PUSH_TOKEN = sub {
        my ($type, @properties) = @_;

        push @tokens, {
            type => $type,
            pos => $pos,
            @properties,
        };
    };

    while ($pos < length($input)) {
        substr($input, $pos) =~ /^(\s+)/
            and $pos += length($1);

        last if $pos >= length($input);

        my $s = substr($input, $pos);

        if ($s =~ /^(return|sub|my)\b/) {
            $PUSH_TOKEN->($1);
            $pos += length($1);
        }
        elsif ($s =~ /^(\w+)\b/) {
            $PUSH_TOKEN->("bareword", name => $1);
            $pos += length($1);
        }
        elsif ($s =~ /^([\$\@]\w+)\b/) {
            $PUSH_TOKEN->("variable", name => $1);
            $pos += length($1);
        }
        elsif (my $type = $PUNCTUATION{substr($s, 0, 1)}) {
            $PUSH_TOKEN->($type);
            $pos += 1;
        }
        else {
            my $fragment = substr($input, $pos, 10);
            die "Do not know how to handle '$fragment...'\n";
        }
    }

    return @tokens;
}

our @EXPORT_OK = qw(
    tokenize
);

1;
