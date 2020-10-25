package Language::Bel::Test::DSL;

use 5.006;
use strict;
use warnings;

use Test::More;
use Language::Bel;

my %RECOGNIZED_DIRECTIVE_NAMES = (
    END => 1,
    ERROR => 1,
    IGNORE => 1,
    TODO => 1,
);

my $AWAITING_INPUT = 0;
my $INPUT_COMPLETION = 1;
my $OUTPUT_COMPLETION = 2;
my $DIAGNOSTIC_COMPLETION = 3;

my $state = $AWAITING_INPUT;

my @ast;
my $accumulated_input;
my $accumulated_output;
my $accumulated_diagnostic;

sub add_test {
    push @ast, {
        type => "TEST",
        input => $accumulated_input,
        output => $accumulated_output,
    };
}

sub add_directive {
    my ($name, $payload) = @_;

    push @ast, {
        type => "DIRECTIVE",
        name => $name,
        payload => $payload,
    };
}

sub add_diagnostic {
    push @ast, {
        type => "DIAGNOSTIC",
        text => $accumulated_diagnostic,
    };
}

sub parse {
    my ($line) = @_;

    $line =~ s/\r?\n$//;

    if ($line =~ /^\s*$/) {
        if ($state == $INPUT_COMPLETION) {
            die "Expected output line, got empty line";
        }
        elsif ($state == $OUTPUT_COMPLETION) {
            add_test();
        }
        elsif ($state == $DIAGNOSTIC_COMPLETION) {
            add_diagnostic();
        }

        $state = $AWAITING_INPUT;
    }
    elsif ($line =~ /^>\s*(.++)/) {
        if ($state == $OUTPUT_COMPLETION) {
            add_test();
        }
        elsif ($state == $INPUT_COMPLETION) {
            die "Expected output, got another input: '$line'";
        }
        elsif ($state != $AWAITING_INPUT) {
            die "Bad state for input: $state";
        }

        $accumulated_input = $1;
        $state = $INPUT_COMPLETION;
    }
    elsif ($line =~ /^\s(.++)/) {
        if ($state != $INPUT_COMPLETION) {
            die "Bad state for input completion: $state";
        }

        $accumulated_input .= "\n$1";
        $state = $INPUT_COMPLETION;
    }
    elsif ($line =~ /^!(\w+): (.++)/) {
        my $name = $1;
        my $payload = $2;

        if ($state == $INPUT_COMPLETION && $name eq "IGNORE") {
            $accumulated_output = "!IGNORE";

            $state = $OUTPUT_COMPLETION;
        }
        elsif ($state == $INPUT_COMPLETION && $name eq "ERROR") {
            $accumulated_output = $line;

            $state = $OUTPUT_COMPLETION;
        }
        elsif ($state != $AWAITING_INPUT) {
            die "Bad state for directive: $state";
        }
        else {
            if (!exists $RECOGNIZED_DIRECTIVE_NAMES{$name}) {
                die "Unrecognized directive '$name'";
            }

            add_directive($name, $payload);

            $state = $AWAITING_INPUT;
        }
    }
    elsif ($line =~ /^ERROR:/) {
        die "Line accidentally begins 'ERROR:' -- did you mean '!ERROR:' ?";
    }
    else {
        if ($state == $AWAITING_INPUT) {
            $accumulated_diagnostic = $line;

            $state = $DIAGNOSTIC_COMPLETION;
        }
        elsif ($state == $INPUT_COMPLETION) {
            $accumulated_output = $line;

            $state = $OUTPUT_COMPLETION;
        }
        elsif ($state == $OUTPUT_COMPLETION) {
            $accumulated_output .= "\n$line";

            $state = $OUTPUT_COMPLETION;
        }
        elsif ($state == $DIAGNOSTIC_COMPLETION) {
            $accumulated_diagnostic .= "\n$line";

            $state = $DIAGNOSTIC_COMPLETION;
        }
        else {
            die "Bad state for freeform text: $state";
        }
    }
}

CHECK {
    @ast = ();

    {
        while (my $line = <main::DATA>) {
            parse($line);
        }
        parse("");

        close main::DATA;
    }

    my $test_count = scalar(grep { $_->{type} eq "TEST" } @ast);
    plan tests => $test_count;

    for my $item (@ast) {
        if ($item->{type} eq "DIRECTIVE" && $item->{name} eq "END") {
            my $payload = $item->{payload};
            eval "END { $payload }";
        }
    }

    my $actual_output = "";
    my $b = Language::Bel->new({ output => sub {
        my ($string) = @_;
        $actual_output = "$actual_output$string";
    } });

    my $todo_toggle = 0;

    for my $item (@ast) {
        if ($item->{type} eq "TEST") {
            my $input = $item->{input};
            my $expected_output = $item->{output};
            $actual_output = "";

            my $scrubbed_input = $input;
            $scrubbed_input =~ s/\r?\n\s*+/ /g;

            my $expecting_error = $expected_output =~ /^!ERROR: (.++)/;
            my $expected_error = $1;

            if ($todo_toggle) {
                eval {
                    $b->read_eval_print($input);
                };

                my $actual_error = $@;
                $actual_error =~ s/\n$//;

                $actual_output =~ s/\n$//;

                # remember, this test is marked 'TODO', so we're expecting the
                # actual output to differ (for now) from the expected one,
                # or an unexpected error occurred
                my $outputs_differ = $actual_output ne $expected_output;
                my $unwanted_error = !$expecting_error && $actual_error;
                ok(
                    $outputs_differ || $unwanted_error,
                    "[TODO] $scrubbed_input ==> $expected_output",
                );

                $todo_toggle = 0;
            }
            elsif ($expecting_error) {
                eval {
                    $b->read_eval_print($input);
                };
                # fudge away the final newline
                $actual_output =~ s/\n$//;

                my $actual_error = $@;
                $actual_error =~ s/\n$//;
                $actual_error ||= "!OUTPUT: $actual_output";
                is(
                    $actual_error,
                    $expected_error,
                    "$scrubbed_input ==> $expected_output",
                );
            }
            else {
                $b->read_eval_print($input);
                # fudge away the final newline
                $actual_output =~ s/\n$//;

                if ($expected_output eq "!IGNORE") {
                    ok(1, "$scrubbed_input ; output ignored");
                }
                else {
                    is(
                        $actual_output,
                        $expected_output,
                        "$scrubbed_input ==> $expected_output",
                    );
                }
            }
        }
        elsif ($item->{type} eq "DIAGNOSTIC") {
            diag($item->{text});
        }
        elsif ($item->{type} eq "DIRECTIVE" && $item->{name} eq "TODO") {
            $todo_toggle = 1;
            diag($item->{payload});
        }
        # everything else, we ignore
    }
}

1;
