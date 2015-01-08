package Panda::Time;
use parent 'Panda::Export';
use 5.012;
use Panda::Lib;
use Panda::Install::Payload;

our $VERSION = '2.8';

require Panda::XSLoader;
Panda::XSLoader::bootstrap('Panda::Date', $VERSION);

__init__();

=head1 NAME

Panda::Time - low-level and very efficient POSIX time/zone functions implementation in C.

=cut

sub __init__ {
    use_embed_zones() unless tzsysdir(); # use embed zones by default where system zones are unavailable
}

sub use_system_zones {
    if (tzsysdir()) {
        tzdir(undef);
    } else {
        warn("Panda::Time[use_system_zones]: this OS has no olson timezone files, you cant use system zones");
    }
}

sub use_embed_zones {
    my $dir = Panda::Install::Payload::payload_dir('Panda::Date');
    return tzdir("$dir/zoneinfo");
}

sub available_zones {
    my $zones_dir = tzdir() or return;
    return _scan_zones($zones_dir, '');
}

sub _scan_zones {
    my ($root, $subdir) = @_;
    my $dir = $subdir ? "$root/$subdir" : $root;
    my @list;
    opendir my $dh, $dir or die "Panda::Time[available_zones]: cannot open $dir: $!";
    while (my $entry = readdir $dh) {
        my $first = substr($entry, 0, 1);
        next if $first eq '.' or $first eq '_';
        my $path = "$dir/$entry";
        if (-d $path) {
            push @list, _scan_zones($root, $subdir ? "$subdir/$entry" : $entry);
        } elsif (-f $path) {
            open my $fh, '<', $path or die "Panda::Time[available_zones]: cannot open $path: $!";
            my $content = readline $fh;
            next unless $content =~ /^TZif/;
            next if $entry =~ /(posixrules|Factory)/;
            push @list, $subdir ? "$subdir/$entry" : $entry;
            close $fh;
        }
    }
    closedir $dh;
    
    return @list;
}

=head1 DESCRIPTION

This module contains low-level C code implementing time functions from scratch. It was written because OS's time functions
are too slow and have various small bugs.

Dates from -2147483648/01/01 00:00:00 till 2147483647/12/31 23:59:59 are supported.

Normally you don't need to use most of these functions directly from perl as it's interface cannot
provide perfomance which these functions have at C level. You should use L<Panda::Date> module.
However you can write our own XS code using these functions or C++ Date class.

=head1 SYNOPSIS

    use Panda::Date;
    # ... work with Panda::Date in local zone of your server

    use Panda::Time 'tzset';
    tzset('Europe/Moscow');
    
    use Panda::Date;
    # ... work with Panda::Date in Europe/Moscow as local zone
    
=head1 FUNCTIONS

=head4 tzset([$zone])

Sets $zone as localzone. If you dont provide $zone, timezone of the server will be set
($ENV{TZ}, /etc/localtime, or whatever your OS considers to be localzone).

Does NOT affect POSIX:tzset(). Only this module's localtime/timelocal/etc functions and L<Panda::Date> classes will follow this timezone.

    # change local zone to 'America/New_York'
    tzset('America/New_York');
    
    # the same (doesnt work in Windows)
    local $ENV{TZ} = 'America/New_York';
    tzset();
    
    # change localzone back to the server's localzone (in case you didn't change $ENV{TZ})
    tzset(); # or tzset(undef) or tzset('')

If you don't want to change localzone, you don't have to call this function directly as it's called implicitly on-demand.

If you provide $zone and no such zone found in zones directory (or timezone file is corrupted), 'UTC0' is used.

=head4 tzget([$zone])

Returns information about timezone $zone (or about server's local zone if $zone is not provided). For information purposes only.

Example of data returned:

    {
        future => {
            hasdst => 1,
            outer => {
                end => {sec => 0, mon => 2, week => 2, hour => 2, day => 0, min => 0 },
                offset => -18000,
                isdst => 0,
                gmt_offset => -18000,
                abbrev => 'EST'
            },
            inner => {
                end => {week => 1, mon => 10, min => 0, hour => 2, day => 0, sec => 0},
                offset => -14400,
                abbrev => 'EDT',
                gmt_offset => -14400,
                isdst => 1
            }
        },
        name => 'America/New_York',
        is_local => 0,
        past => {
            abbrev => 'LMT',
            offset => -17762
        },
        transitions => [
            {
                offset => -17762,
                leap_delta => 0,
                abbrev => 'LMT',
                start => '-9223372036854775808',
                leap_corr => 0,
                gmt_offset => -17762,
                isdst => 0
            },
            {
                offset => -18000,
                leap_delta => 0,
                gmt_offset => -18000,
                isdst => 0,
                start => '-2717650800',
                abbrev => 'EST',
                leap_corr => 0
            },
            ...
        ]
    }

=head4 use_system_zones()

Use your OS's timezones dir. This is default behaviour if your OS has /usr/share/zoneinfo DB. Otherwise embedded zones
are used by default (on MS Windows).

If your OS doesn't have /usr/share/zoneinfo DB, this function warns and does nothing.

=head4 use_embed_zones()

Use timezone files which come with this module.

=head4 tzdir([$newdir])

Sets or returns current timezones directory.
If there was an error (too long path, !exists, !readable, etc) returns false and leaves tzdir unchanged.

    say tzdir(); # prints /usr/share/zoneinfo (on UNIX)
    tzdir('/home/frank/myzones'); # use /home/frank/myzones as timezones DB
    say tzdir(); # prints /home/frank/myzones
    tzset('Europe/Moscow'); # set /home/frank/myzones/Europe/Moscow as localzone

=head4 available_zones()

Returns list of all available timezones (names) in tzdir().

=head4 tzname()

The name of localzone. Note that in some cases the real name of localzone is not known
(for example when localzone is retrieved from /etc/localtime file, tzname() will return ':/etc/localtime')

=head4 gmtime($epoch)

Behaves exactly like perl's gmtime.

The returned year is in human-readable form (not year-1900). Month is [0-11]. The same applies for all further time functions.

=head4 localtime($epoch)

Behaves exactly like perl's localtime.

=head4 timegm($sec, $min, $hour, $day, $mon, $year, [$isdst])

Behaves exactly like POSIX's timegm.

=head4 timegmn($sec, $min, $hour, $day, $mon, $year)

Same as timegm() except for the arguments which have to be non-constant values because they are normalized during calculations.

=head4 timelocal($sec, $min, $hour, $day, $mon, $year, [$isdst])

Behaves exactly like POSIX's timelocal.

=head4 timelocaln($sec, $min, $hour, $day, $mon, $year, [$isdst])

Same as timelocal() except for the arguments which have to be non-constant values because they are normalized during calculations.

=head1 SUPPORTED OS

Tested on FreeBSD, Linux, MacOSX, Windows 2003, Windows 7.

I believe all of UNIX-like and Windows-like systems are supported.

Timezones are supported in Olson DB format (V1,2,3).

=head1 C INTERFACE

=head2 SYNOPSIS

All functions/types/constants are in panda::time:: namespace (so actually you need C++ to use them).

    #include <stdio.h>
    #include <panda/time.h>
    using panda::time::tzset;
    using panda::time::localtime;
    
    tzset('Europe/Moscow');

    time_t epoch = 1000000000;    
    datetime date;
    localtime(epoch, &date);
    printf(
        "epoch %lli is %04d/%02d/%02d %02d:%02d:%02d, isdst=%d, GMT offset is %d, zone abbreviation is %s",
        epoch, date.year, date.mon+1, date.mday, date.hour, date.min, date.sec, date.isdst, date.gmtoff, date.zone
    );
    
    epoch = timelocal(&date);
    
=head2 FUNCTIONS

=head4 void tzset (const char* zone = NULL)

See L</tzset([$zone])>.

=head4 tz* tzget (const char* zone)

Returns timezone object pointer which contains info about timezone 'zone' (or about server's local zone if zone == NULL or "").

You can then use this pointer to perform time calculations in any zone you want without setting local zone via C<tzset()>.
You can also have as many timezones in parralel as you want.

Remember that this pointer is only valid until next C<tzdir(newdir)> and possibly C<tzset()> call.
If you want this zone pointer to be valid forever call C<retain()> on timezone object.

When you call C<tzget(zone)> for the first time it reads and parses timezone file from disk. Futher calls with the same zone
returns cached pointer.

=head4 tz* tzlocal ()

Same as C<tzget(NULL)>.

=head4 const char* tzdir ()

Returns current timezone DB directory.

=head4 bool tzdir (const char* newdir)

See L</tzdir([$newdir])>. C<tzdir(NULL)> sets tzdir to tzsysdir().

=head4 const char* tzsysdir ()

Returns system timezones dir if any (usually /usr/share/zoneinfo), otherwise returns NULL.

=head4 void timezone->retain ()

Captures timezone object so that it remains valid until C<timezone->release()> call.

=head4 void timezone->release ()

Releases timezone object so that it can be removed from memory if no longer used by any other consumers.

Remember: you must not call C<release()> unless you've called C<retain()>.

=head4 void gmtime (time_t epoch, datetime* result)

Behaves like POSIX's C<gmtime_r()> but much faster.

The returned year is in human-readable form (not year-1900). Month is [0-11]. The same applies for all further time functions.

=head4 time_t timegm (datetime* date)

Behaves like POSIX's C<timegm()> but much faster.

=head4 time_t timegml (datetime* date)

More efficient (lite) version of C<timegm()>, doesn't change (normalize) values in date.

=head4 void localtime (time_t epoch, datetime* result)

Behaves like POSIX's C<localtime_r()> but much faster.

=head4 time_t timelocal (datetime* date)

Behaves like POSIX's C<timelocal()> but much faster.

=head4 time_t timelocall (datetime* date)

More efficient (lite) version of C<timelocal()>, doesn't change (normalize) values in date.

=head4 void anytime (time_t epoch, datetime* result, const tz* zone)

Performs epoch -> datetime calculations in timezone 'zone'.

The following two lines are equivalent:

    localtime(epoch, date);
    anytime(epoch, date, tzlocal());

=head4 time_t timeany (datetime* date, const tz* zone)

Performs datetime -> epoch calculations in timezone 'zone'.

The following two lines are equivalent:

    epoch = timelocal(date);
    epoch = timeany(date, tzlocal());
    
=head4 time_t timeanyl (datetime* date, const tz* zone)

More efficient (lite) version of C<timeany()>, doesn't change (normalize) values in date.

=head4 igmtime(), itimegm(), itimegml()

Inline versions for even more perfomance.

=head4 size_t strftime (char* buf, size_t maxsize, const char* format, const datetime* timeptr)

Behaves like POSIX's C<strftime()>.

=head4 void dt2tm (struct tm &to, datetime &from), void tm2dt (datetime &to, struct tm &from)

Performs struct tm <-> struct datetime convertations

=head1 CAVEATS

C<$ENV{TZ}> doesn't work in Windows. To set $zone as localzone, you should write

	tzset($zone);

to produce platform-independent code.

While developing all the time functions from scratch and comparing results with POSIX's system functions i discovered
that many operating systems have buggy implementations of localtime/timelocal functions which causes them to return
wrong results in case of certain dates. Therefore in such cases the result of panda::time::* functions won't match with
POSIX functions because panda::time handles all these cases correctly.

Bugs i discovered:

=head4 Linux and FreeBSD (and possibly more Unix-like systems)

=over

=item timelocal cannot correctly handle forward time jump at last transition.

     For example Europe/Moscow, date "2011/03/27 02:00:00"
     Must return 1301180400 ("2011/03/27 03:00:00")
     In fact returns
       - linux: 1301176800 ("2011/03/27 01:00:00")
       - freebsd: -1
     If transition is not the last one, it works correctly:
     "2010/03/28 02:00:00" returns 1269730800 ("2010/03/28 03:00:00")

=item localtime/timelocal handles DST transitions in future (outside of transitions) incorrectly when using leap second zones

     $ TZ=right/Australia/Melbourne perl -E 'say scalar localtime 4284028799'
     Sun Oct  4 01:59:34 2105
     $ TZ=right/Australia/Melbourne perl -E 'say scalar localtime 4284028800'
     Sun Oct  4 02:59:35 2105

=back

=head4 FreeBSD only

=over

=item America/Anchorage timezone behaves like it has no POSIX string (no DST changes after last transition)

=item timelocal cannot handle dates before year 1900

=item Wrong forward jump normalization with non-DST transitions

     - Simple forward jump 1h somewhy normalized back
      CORRECT: epoch=-1539492257 (1921/03/21 00:15:43  MSD) from 1921/03/20 23:15:43 DST=-1 (Europe/Moscow)
      POSIX:   epoch=-1539495857 (1921/03/20 22:15:43  MSD) from 1921/03/20 23:15:43 DST=-1 (Europe/Moscow)
     - Forward jump 2h normalized just 1h
      CORRECT: epoch=-1627961251 (1918/06/01 01:03:17 MDST) from 1918/05/31 23:03:17 DST=-1 (Europe/Moscow)
      POSIX:   epoch=-1627964851 (1918/06/01 00:03:17 MDST) from 1918/05/31 23:03:17 DST=-1 (Europe/Moscow)
     - Simple forward jump 1h somewhy normalized 30min
      CORRECT: epoch=372787481 (1981/10/25 03:34:41 LHST) from 1981/10/25 02:34:41 DST=-1 (Australia/Lord_Howe)
      POSIX:   epoch=372785681 (1981/10/25 03:04:41 LHST) from 1981/10/25 02:34:41 DST=-1 (Australia/Lord_Howe)
     - Simple forward jump 1h somewhy normalized 2h
      CORRECT: epoch=449595541 (1984/04/01 01:39:01 CHOST) from 1984/04/01 00:39:01 DST=-1 (Asia/Choibalsan)
      POSIX:   epoch=449599141 (1984/04/01 02:39:01 CHOST) from 1984/04/01 00:39:01 DST=-1 (Asia/Choibalsan)
     - Forward jump 3h normalized 2h
      CORRECT: epoch=354905851 (1981/04/01 04:57:31 MAGST) from 1981/04/01 01:57:31 DST=-1 (Asia/Ust-Nera)
      POSIX:   epoch=354902251 (1981/04/01 03:57:31 MAGST) from 1981/04/01 01:57:31 DST=-1 (Asia/Ust-Nera)

=back

=head4 Linux only

=over

=item Complex bug with static variable deep inside POSIX code

Steps to reproduce: (TZ=Europe/Moscow, date strings are for compactness, actually 'struct tm' required)
    
    mktime("1998/10/25 03:-1:61"); // returns 909273601 (Sun Oct 25 03:00:01 1998) - that's ok
    mktime("2011/-2/1 00:00:00"); // returns 1285876800 (Fri Oct  1 00:00:00 2010) - that's ok
    // now run the first line again
    mktime("1998/10/25 03:-1:61"); // returns 909270001 (Sun Oct 25 02:00:01 1998) - OOPS
    // again and again
    mktime("1998/10/25 03:-1:61"); // returns 909270001 (Sun Oct 25 02:00:01 1998) - OOPS forever :(

=back

=head1 PERFOMANCE

Tests were performed on MacOSX Lion, Core i7 3.2Ghz, clang 3.3.

    -------------------------------------------------------------------------------------------------
    |         Function        |     panda      |  libc(MacOSX)  |   libc(Linux)  |   libc(FreeBSD)  |
    -------------------------------------------------------------------------------------------------
    | gmtime(epoch, &date)    |     53 M/s     |     11 M/s     |     15 M/s     |       12 M/s     |
    | timegm(&date)           |     30 M/s     |    0.4 M/s     |     10 M/s     |     0.15 M/s     |
    | timegml(&date)          |    135 M/s     |       --       |       --       |        --        |
    | localtime(epoch, &date) |     26 M/s     |    5.5 M/s     |      7 M/s     |        3 M/s     |
    | timelocal(&date)        |     23 M/s     |    0.5 M/s     |    1.2 M/s     |      0.1 M/s     |
    | timelocall(&date)       |     50 M/s     |       --       |       --       |        --        |
    -------------------------------------------------------------------------------------------------

=head1 AUTHOR

Pronin Oleg <syber@cpan.org>, Crazy Panda, CP Decision LTD

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
 
1;
