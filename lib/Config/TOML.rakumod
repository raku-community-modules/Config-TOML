use Config::TOML::Dumper;
use Config::TOML::Parser;
use X::Config::TOML;

unit module Config::TOML;

multi sub from-toml(
    Str:D $content,
    *%opts (Int :date-local-offset($))
    --> Hash:D
) is export
{
    my %toml = Config::TOML::Parser.parse($content, |%opts).made
        or die(X::Config::TOML::ParseFailed.new(:$content));
}

multi sub from-toml(
    Str:D :$file! where .so,
    *%opts (Int :date-local-offset($))
    --> Hash:D
) is export
{
    my %toml = Config::TOML::Parser.parsefile($file, |%opts).made
        or die(X::Config::TOML::ParsefileFailed.new(:$file));
}

sub to-toml(
    Associative:D $container,
    *%opts (
        # indent level of table keys relative to parent table (whitespace)
        UInt :indent-subkeys($) = 0,
        # indent level of subtables relative to parent table (whitespace)
        UInt :indent-subtables($) = 2,
        # margin between tables (newlines)
        UInt :margin-between-tables($) = 1,
        # pad inline array/hash delimiters (`[`, `]`, `{`, `}`) with whitespace
        Bool :prefer-padded-delimiters($) = True,
        # use string literals in place of basic strings whenever possible
        Bool :prefer-string-literals($) = True,
        # intersperse underlines in numbers for readability
        Bool :prefer-underlines-in-numbers($) = True,
        # the threshold # elements at which to convert array to multiline array
        UInt :threshold-multiline-array($) = 5,
        # the threshold length at which to convert string to multiline string
        UInt :threshold-multiline-string($) = 72,
        # the threshold # digits at which to intersperse underlines in numbers
        UInt :threshold-underlines-in-numbers($) = 5
    )
    --> Str:D
) is export
{
    my Str:D $toml = Config::TOML::Dumper.new.dump($container);
}

=begin pod

=head1 NAME

Config::TOML - TOML file parser and writer

=head1 DESCRIPTION

Config::TOML exports two subroutines: C<from-toml> and C<to-toml>.

=head1 SYNOPSIS

TOML to Raku:

=begin code :lang<raku>

use Config::TOML;

# parse toml from string
my $toml = Q:to/EOF/;
[server]
host = "192.168.1.1"
ports = [ 8001, 8002, 8003 ]
EOF
my %toml = from-toml($toml);

# parse toml from file
my $file = 'config.toml';
my %toml = from-toml(:$file);

=end code

Raku to TOML:

=begin code :lang<raku>

use Config::TOML;
my %h = :a<alpha>, :b<bravo>, :c<charlie>;
to-toml(%h);

=end code

=head1 ADVANCED USAGE

=head2 Specifying a custom local offset for TOML date values

TOML date values can take three different forms:

=item L<RFC 3339|http://tools.ietf.org/html/rfc3339> timestamps
(C<YYYY-MM-ddThh:mm:ss.ffff+zz>)
=item RFC 3339 timestamps with the local offset omitted
(C<YYYY-MM-ddThh:mm:ss.ffff>)
=item Standard calendar dates (C<YYYY-MM-dd>)

Config::TOML builds Raku C<Date>s from standard calendar dates.

By default, Config::TOML builds Raku C<DateTime>s from TOML datetime
values that do not include a local offset using the host machine's local
offset. To override the default behavior of using the host machine's
local offset for date values where the offset is omitted, pass the
C<date-local-offset> named argument (with an integer value) to
C<from-toml>:

=begin code :lang<raku>

my $cfg = slurp 'config.toml';

# assume UTC when local offset unspecified in TOML dates
my %toml = from-toml($cfg, :date-local-offset(0));

=end code

To calculate a target timezone's local offset for the
C<date-local-offset> named argument value, multiply its
L<UTC offset|https://en.wikipedia.org/wiki/List_of_UTC_time_offsets>
hours by 60, add to this its UTC offset minutes, and multiply the
result by 60.

=begin table

Timezone            | UTC Offset | Calculation
---                 | ---        | ---
Africa/Johannesburg | UTC+02:00  | ((2 * 60) + 0) * 60 = 7200
America/Los_Angeles | UTC-07:00  | ((-7 * 60) + 0) * 60 = -25200
Asia/Seoul          | UTC+09:00  | ((9 * 60) + 0) * 60 = 32400
Australia/Sydney    | UTC+10:00  | ((10 * 60) + 0) * 60 = 36000
Europe/Berlin       | UTC+01:00  | ((1 * 60) + 0) * 60 = 3600
UTC                 | UTC±00:00  | ((0 * 60) + 0) * 60 = 0

=end table

To more easily ascertain your host machine's local offset, open a Raku
repl and print the value of C<$*TZ>.

=head1 AUTHOR

Andy Weidenbaum

=head1 COPYRIGHT AND LICENSE

Copyright 2015 - 2022 Andy Weidenbaum

Copyright 2024 Raku Community

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.

=end pod

# vim: expandtab shiftwidth=4
