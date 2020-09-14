package Language::Bel::Globals::SVG;

use 5.006;
use strict;
use warnings;

use POSIX qw(ceil);

use Exporter 'import';

sub round_up_to_10 {
    my ($value) = @_;

    return ceil($value / 10) * 10;
}

sub generate {
    my $globals_source_file = "lib/Language/Bel/Globals/Source.pm";
    open my $SOURCE, "<", $globals_source_file
        or die "Cannot open $globals_source_file: $!";

    sub trim_nl {
        my ($s) = @_;

        $s =~ s/\r?\n$//;
        return $s;
    }

    # read source until data
    while (1) {
        my $line = trim_nl(<$SOURCE> || "");
        last if $line =~ /__DATA__/;
    }

    my @definitions;
    while (!eof($SOURCE)) {
        # read source definition
        my $source_definition = "";
        while (my $line = trim_nl(<$SOURCE> || "")) {
            $source_definition .= "$line\n";
        }
        
        if ($source_definition =~ /^; skip (\S+) \[waiting for (\w+(?:, \w+)*)\]$/) {
            my $name = $1;
            my $features = $2;
            push @definitions, [$name, $features];
        }
        else {
            push @definitions, ["<anon>", "+1"];
        }
    }

    close $SOURCE;

    my @output;

    my $color1 = "#c96424";
    my $color2 = "#f2cc86";
    my $color3 = "#ffa502";
    my $color4 = "#82baff";
    my $color5 = "#2b568c";

    push(@output, "<svg
        xmlns='http://www.w3.org/2000/svg'
        width='{{WIDTH}}'
        height='{{HEIGHT}}'
        viewbox='0 0 {{WIDTH}} {{HEIGHT}}'
        onclick=''>\n");
    push(@output, "  <style>
        text {
          font-size: 18px;
          font-family: Calibri, sans serif;
        }

        .box {
          fill: none;
          stroke: black;
          stroke-width: 0.5;
        }

        .done               { fill: white; }
        .feature-ccc        { fill: $color1; }
        .feature-reader     { fill: $color2; }
        .feature-backquotes { fill: $color3; }
        .feature-printer    { fill: $color4; }
        .feature-chars      { fill: $color5; }
      </style>\n\n");

    my $x = 0;
    my $y = 0;
    my $x_offset = 151;
    my $y_offset = 1;
    my $last_features = "+1";
    my $box_size = 17;

    my $max_x = 0;
    my $max_y = 0;

    while (my $def = shift(@definitions)) {
        my ($name, $features) = @$def;
        $name =~ s/</\&lt;/g;
        $name =~ s/>/\&gt;/g;
        $name =~ s/'/\&quot;/g;
        my $colorclass = $features eq "+1"
            ? "done"
            : join(" ", map { "feature-$_" } split(", ", $features));

        if ($last_features ne $features) {
            $x_offset += 5;
            $y_offset += 5;
        }

        my $x20 = $x_offset + 20 * $x;
        my $y20 = $y_offset + 20 * $y;

        $max_x = $max_x > $x20 + $box_size ? $max_x : $x20 + $box_size;
        $max_y = $max_y > $y20 + $box_size ? $max_y : $y20 + $box_size;

        push(@output, "  <rect
        x='$x20'
        y='$y20'
        width='$box_size'
        height='$box_size'
        class='$colorclass box'
        title='$name'
      />\n");
        ++$x;
        if ($x >= 21) {
            $x = 0;
            ++$y;
        }
        $last_features = $features;
    }

    my @FEATURES = qw<done ccc reader backquotes printer chars>;
    $y = $y_offset + 20 * $y - 30 * scalar(@FEATURES);
    for my $feature (@FEATURES) {
        my $class = $feature eq "done"
            ? $feature
            : "feature-$feature";
        push(@output, "  <rect
        x='20'
        y='$y'
        width='$box_size'
        height='$box_size'
        class='$class box'
        title='$feature'
      />\n");
        my $text_y = $y + 15;
        push(@output, "  <text
        x='50'
        y='$text_y'
      >$feature</text>\n");
        $y += 30;
    }

    push(@output, "</svg>\n");

    my $width = round_up_to_10($max_x + 5);
    my $height = round_up_to_10($max_y + 5);

    my $output = join("", @output);
    $output =~ s/\{\{WIDTH\}\}/$width/g;
    $output =~ s/\{\{HEIGHT\}\}/$height/g;

    return $output;
}

our @EXPORT_OK = qw(
    generate
);

1;
