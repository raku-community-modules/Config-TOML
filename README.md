[![Actions Status](https://github.com/raku-community-modules/Config-TOML/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Config-TOML/actions) [![Actions Status](https://github.com/raku-community-modules/Config-TOML/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Config-TOML/actions) [![Actions Status](https://github.com/raku-community-modules/Config-TOML/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/Config-TOML/actions)

NAME
====

Config::TOML - TOML file parser and writer

DESCRIPTION
===========

Config::TOML exports two subroutines: `from-toml` and `to-toml`.

SYNOPSIS
========

TOML to Raku:

```raku
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
```

Raku to TOML:

```raku
use Config::TOML;
my %h = :a<alpha>, :b<bravo>, :c<charlie>;
to-toml(%h);
```

ADVANCED USAGE
==============

Specifying a custom local offset for TOML date values
-----------------------------------------------------

TOML date values can take three different forms:

  * [RFC 3339](http://tools.ietf.org/html/rfc3339) timestamps (`YYYY-MM-ddThh:mm:ss.ffff+zz`)

  * RFC 3339 timestamps with the local offset omitted (`YYYY-MM-ddThh:mm:ss.ffff`)

  * Standard calendar dates (`YYYY-MM-dd`)

Config::TOML builds Raku `Date`s from standard calendar dates.

By default, Config::TOML builds Raku `DateTime`s from TOML datetime values that do not include a local offset using the host machine's local offset. To override the default behavior of using the host machine's local offset for date values where the offset is omitted, pass the `date-local-offset` named argument (with an integer value) to `from-toml`:

```raku
my $cfg = slurp 'config.toml';

# assume UTC when local offset unspecified in TOML dates
my %toml = from-toml($cfg, :date-local-offset(0));
```

To calculate a target timezone's local offset for the `date-local-offset` named argument value, multiply its [UTC offset](https://en.wikipedia.org/wiki/List_of_UTC_time_offsets) hours by 60, add to this its UTC offset minutes, and multiply the result by 60.

<table class="pod-table">
<thead><tr>
<th>Timezone</th> <th>UTC Offset</th> <th>Calculation</th> <th></th>
</tr></thead>
<tbody>
<tr> <td>Africa/Johannesburg</td> <td>UTC+02:00</td> <td>((2 * 60)</td> <td>0) * 60 = 7200</td> </tr> <tr> <td>America/Los_Angeles</td> <td>UTC-07:00</td> <td>((-7 * 60)</td> <td>0) * 60 = -25200</td> </tr> <tr> <td>Asia/Seoul</td> <td>UTC+09:00</td> <td>((9 * 60)</td> <td>0) * 60 = 32400</td> </tr> <tr> <td>Australia/Sydney</td> <td>UTC+10:00</td> <td>((10 * 60)</td> <td>0) * 60 = 36000</td> </tr> <tr> <td>Europe/Berlin</td> <td>UTC+01:00</td> <td>((1 * 60)</td> <td>0) * 60 = 3600</td> </tr> <tr> <td>UTC</td> <td>UTC±00:00</td> <td>((0 * 60)</td> <td>0) * 60 = 0</td> </tr>
</tbody>
</table>

To more easily ascertain your host machine's local offset, open a Raku repl and print the value of `$*TZ`.

AUTHOR
======

Andy Weidenbaum

COPYRIGHT AND LICENSE
=====================

Copyright 2015 - 2022 Andy Weidenbaum

Copyright 2024 Raku Community

This is free and unencumbered public domain software. For more information, see http://unlicense.org/ or the accompanying UNLICENSE file.

