package Language::Bel::Test;

use 5.006;
use strict;
use warnings;

use Test::More;
use Language::Bel;
use Language::Bel::Reader qw(
    read_partial
);

use Exporter 'import';

my $actual_output = "";
my $b = Language::Bel->new({ output => sub {
    my ($string) = @_;
    $actual_output = "$actual_output$string";
} });

sub bel_todo {
    my ($expr, $expected_output, $expected_todo_error) = @_;

    $expected_todo_error ||= "";
    $actual_output = "";
    eval {
        $b->read_eval_print($expr);
    };
    $actual_output =~ s/\r?\n$//;

    my $error = $@;
    $error =~ s/\n$//;
    if (!$error && $actual_output eq $expected_output) {
        ok(0, "UNEXPECTED SUCCESS $expr ==> $expected_output");
    }
    else {
        my $message = $error eq $expected_todo_error
            ? "'$error'"
            : $error
                ? "Expected '$expected_todo_error', got '$error'"
                : "Expected '$expected_output', got '$actual_output'";
        ok(
            $expected_todo_error && $error && $error eq $expected_todo_error
            || !$expected_todo_error && !$error && $actual_output ne $expected_output,
            "TODO $expr ($message)"
        );
    }
}

sub visit {
    my ($dir, $fn_ref, $prefix) = @_;
    $prefix ||= "";

    # un-taint $dir
    $dir =~ /^(\w+)$/;
    $dir = $1;
    chdir($dir);

    for my $file (<*>) {
        my $name = "$prefix$dir/$file";
        if ($name =~ /\.pm$/) {
            $fn_ref->($name, $file);
        }

        if (-d $file) {
            visit($file, $fn_ref, "$prefix$dir/");
        }
    }
    chdir("..");
}

sub output_of_eval_file {
    my ($source_file) = @_;

    my $output = "";
    my $b = Language::Bel->new({ output => sub {
        my ($string) = @_;
        $output = "$output$string";
    } });

    my $source;
    {
        local $/;
        open my $fh, '<', $source_file
            or die "can't open $source_file for reading: $!";
        $source = <$fh>;
    }

    while ($source) {
        my $p = read_partial($source);
        my $ast = $p->{ast};
        my $next_pos = $p->{pos};

        $b->eval($ast);

        $source = substr($source, $next_pos);
        $source =~ s/^\s+//;
    }

    return $output;
}

our @EXPORT = qw(
    bel_todo
    output_of_eval_file
    visit
);

1;
