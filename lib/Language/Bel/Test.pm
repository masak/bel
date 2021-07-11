package Language::Bel::Test;

use 5.006;
use strict;
use warnings;

use Test::More;
use Language::Bel;
use Language::Bel::Reader qw(
    read_partial
);
use Language::Bel::Bytecode qw(
    belify_bytefunc
);
use Language::Bel::Compiler qw(
    compile
);


use Exporter 'import';

my $actual_output = "";
my $prepared_input = "Bel 9 from Outer Space\n"; 
my $b = Language::Bel->new({
    output => sub {
        my ($string) = @_;
        $actual_output = "$actual_output$string";
    },
    read_char => sub {
        my $chr = substr($prepared_input, 0, 1);
        $prepared_input = substr($prepared_input, 1);
        return $chr;
    },
});

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

sub for_each_line_in_file {
    my ($filename, $line_callback) = @_;

    open my $fh, "<", $filename
        or die "can't open $filename: $!";

    my $exit_loop_callback_was_called = 0;
    my $exit_loop_callback = sub {
        $exit_loop_callback_was_called = 1;
    };

    while (my $line = <$fh>) {
        $line =~ s/\r?\n$//;
        $line_callback->($line, $exit_loop_callback);
        if ($exit_loop_callback_was_called) {
            last;
        }
    }

    close $fh
        or die "can't close $filename";
}

sub slurp_file {
    my ($filename) = @_;

    my @lines;
    for_each_line_in_file($filename, sub {
        my ($line) = @_;
        push @lines, $line;
        push @lines, "\n";
    });

    return join("", @lines);
}

sub deindent {
    my ($text) = @_;

    my $result = join("\n", map { $_ && substr($_, 4) } split(/\n/, $text));
    $result =~ s/^\n//;
    $result .= "\n";
    return $result;
}

sub test_compilation {
    my ($source, $target) = @_;
    $source =~ /^\(def (\S+)/
        or die "Couldn't parse out the name from '$source'";
    my $name = $1;

    is belify_bytefunc(compile($source)),
        $target,
        "compilation of `$name`";
}

our @EXPORT = qw(
    bel_todo
    deindent
    for_each_line_in_file
    output_of_eval_file
    slurp_file
    test_compilation
    visit
);

1;
