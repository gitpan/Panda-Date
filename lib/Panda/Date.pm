package Panda::Date;
use parent 'Panda::Export';
use 5.012;
use Panda::Time;
use Panda::Date::Rel;
use Panda::Date::Int;

our $VERSION = '2.0';

=head1 NAME

Panda::Date - fast Date framework in C.

=cut

use Panda::Export {
    E_OK         => 0,
    E_UNPARSABLE => 1,
    E_RANGE      => 2,
    SEC          => rdate_const("1s"),
    MIN          => rdate_const("1m"),
    HOUR         => rdate_const("1h"),
    DAY          => rdate_const("1D"),
    MONTH        => rdate_const("1M"),
    YEAR         => rdate_const("1Y"),
};

use overload
    '""'     => \&to_string,
    'bool'   => \&to_bool,
    '0+'     => \&to_number,
    '<=>'    => \&compare,
    'cmp'    => \&compare,
    '+'      => \&add_new,
    '+='     => \&add,
    '-'      => \&subtract_new,
    '-='     => \&subtract,
    '='      => sub { $_[0] },
    fallback => 1;

=head1 DESCRIPTION

Panda::Date is almost fully compatible with L<Class::Date>, but has several more features and much greater perfomance.
It is written fully in C/C++.

Panda::Date supports dates between -2147483648/01/01 00:00:00 and 2147483647/12/31 23:59:59.

With Panda::Date you can perform some operations even faster than in plain C program using stdlibc functions.
See L<Panda::Time> why.

=head1 SYNOPSIS

    use Panda::Time qw/tzset/;
    use Panda::Date qw/now date today rdate idate :const/;
    
    my $date = Panda::Date->new($epoch); # using server's local timezone
    $date = Panda::Date->new([$y,$m,$d,$h,$m,$s]);
    $date = Panda::Date->new({year => $y, month => $m, day => $d, hour => $h, min => $m, sec => $s});
    $date = Panda::Date->new("2013-03-05 23:45:56");
    $date = now(); # same as Panda::Date->new(time()) but faster
    $date = today(); # same as Panda::Date->new(time())->truncate but faster
    
    # create using function 'date'
    tzset('Europe/Moscow'); # using 'Europe/Moscow' as server's local timezone
    $date = date [$year,$month,$day,$hour,$min,$sec]; 
    $date = date { year => $year, month => $month, day => $day, hour => $hour, min => $min, sec => $sec };
    $date = date "2001/11/12 07:13:12";
    $date = date 123456789;
    $date = date("2001/11/12 07:13:12", 'America/New_York'); # $date operates in custom time zone
    
    # creating relative date object
    # (normally you don't need to create this object explicitly)
    $reldate = new Panda::Date::Rel "3Y 1M 3D 6h 2m 4s";
    $reldate = new Panda::Date::Rel "6Y";
    $reldate = new Panda::Date::Rel $secs;  # secs
    $reldate = new Panda::Date::Rel [$year,$month,$day,$hour,$min,$sec];
    $reldate = new Panda::Date::Rel { year => $year, month => $month, day => $day, hour => $hour, min => $min, sec => $sec };
    $reldate = rdate "-1M -3D 6h";
    $reldate = 3*MONTH; # "3M"
    $reldate = 2*YEAR + MONTH - 30*DAY; # "2Y 1M -30D"
    print $reldate/2; # 1Y 5h 14m 32s
    $reldate = YEAR/2 + HOUR/2; # 6M 30m
    
    $date;              # prints the date in default output format (ISO/SQL format)
    $date->epoch;       # unix timestamp
    $date->year;        # year, e.g: 2001
    $date->_year;       # year - 1900, e.g. 101
    $date->yr;          # 2-digit year 0-99, e.g 1
    $date->mon;         # month 1..12
    $date->month;       # same as prev.
    $date->_mon;        # month 0..11
    $date->_month;      # same as prev.
    $date->day;         # day of month
    $date->mday;        # day of month
    $date->day_of_month;# same as prev.
    $date->hour;
    $date->min;
    $date->minute;      # same as prev.
    $date->sec;
    $date->second;      # same as prev.
    $date->wday;        # 1 = Sunday
    $date->day_of_week; # same as prev.
    $date->_wday;       # 0 = Sunday
    $date->ewday;       # 1 = Monday, 7 = Sunday
    $date->yday;        # [1-366]
    $date->day_of_year; # same as prev.
    $date->_yday;       # [0-365]
    $date->isdst;       # DST?
    $date->daylight_savings; # same as prev.
    $date->strftime($format);
    $date->monname;     # name of month, eg: March
    $date->monthname;   # same as prev.
    $date->wdayname;    # Thursday
    $date->day_of_weekname # same as prev.
    $date->hms          # 01:23:45
    $date->ymd          # 2000/02/29
    $date->mdy          # 02/29/2000
    $date->dmy          # 29/02/2000
    $date->meridiam     # 01:23 AM
    $date->ampm         # AM/PM
    $date->string       # 2000-02-29 12:21:11 (format can be changed)
    "$date"             # same as prev.
    $date->iso          # 2000-02-29 12:21:11
    $date->gmtoff       # current offset from UTC (in seconds)
    $date->tzname       # returns the timezone name (EST, EET, etc)
    $date->tzlocal      # true if $date is in local time zone
    $date->tz           # returns timezone info
    $date->tz('GMT+5')  # changes $date's timezone (saving YMDhms)
    $date->to_tz('UTC') # changes $date's timezone (saving epoch)
    
    ($year,$month,$day,$hour,$min,$sec)=$date->array;
    ($year,$month,$day,$hour,$min,$sec)=@{ $date->aref };
    # !! $year: 1900-, $month: 1-12
    
    ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=$date->struct;
    ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=@{ $date->sref };
    # !! $year: 0-, $month: 0-11
    
    %hash=$date->hash;
    # !! $hash{year}: 1900-, $hash{month}: 1-12
    $hash=$date->href; # $hash can be reused as a constructor
    print $hash->{year}."-".$hash->{month}. ... $hash->{sec} ... ;
    
    # constructing new date based on an existing one:
    $new_date = $date->clone;
    $new_date = $date->clone({year => 1977, sec => 14, tz => 'Australia/Melbourne'});
    # valid keys: year, _year, month, _month, day, hour, min, sec, tz
    
    $date->month_begin  # First day of the month (date object)
    $date->month_end    # Last day of the month
    $date->days_in_month # 28..31
    
    # changing date stringify format globally
    Panda::Date::string_format("%Y%m%d%H%M%S");
    print $date       # result: 20011222000000
    Panda::Date::string_format(undef);
    print $date       # result: 2000-02-29 12:21:11
    Panda::Date::string_format("%Y/%m/%d");
    print $date       # result: 1994/10/13
    
    # error handling
    $a = date($date_string);
    if ($a) { # valid date
      ...
    } else { # invalid date
      if ($a->error == E_UNPARSABLE) { ... }
      print $a->errstr;
    }
    
    # date range check
    Panda::Date::range_check(0); # this is the default
    print date("2001-02-31"); # will print 2001-03-03
    Panda::Date::range_check(1);
    print date("2001-02-31"); # will print nothing
    
    # getting values of a relative date object
    int($reldate);         # reldate in seconds (assumed 1 month = 2_629_744 secs)
    "$reldate";            # reldate in "1Y 2M 3D 4h 5m 6s" format
    $reldate->year;
    $reldate->mon;
    $reldate->month;       # same as prev.
    $reldate->day;
    $reldate->hour;
    $reldate->min;
    $reldate->minute;      # same as prev.
    $reldate->sec;         # same as $reldate
    $reldate->second;      # same as prev.
    $reldate->to_sec;      # relative date in seconds
    $reldate->to_min;      # relative date in minutes
    $reldate->to_hour;     # relative date in hours
    $reldate->to_day;      # relative date in days
    $reldate->to_month;    # relative date in months
    $reldate->to_year;     # relative date in years
     
    # arithmetic with dates:
    print date([2001,12,11,4,5,6])->truncate; # will print "2001-12-11"
    
    $new_date = $date+$reldate;
    $date2    = $date+'3Y 2D';   # 3 Years and 2 days
    $date3    = $date+[1,2,3];   # $date plus 1 year, 2 months, 3 days
    
    $new_date = $date-$reldate;
    $date2    = $date-'3Y';      # 3 Yearss
    $date3    = $date-[1,2,3];   # $date minus 1 year, 2 months, 3 days
    
    $intdate  = $date1-$date2;
    $intdate2 = date('2000-11-12')-'2000-11-10';
    $intdate3 = $date3-'1977-11-10';
    
    $intdate = date("2013-10-25") - "2012-03-10";
    $intdate->from;                  # lower date in interval (2012-03-10)
    $intdate->till;                  # upper date in interval (2013-10-25)
    $reldate = $intdate->relative;   # relative date ("1Y 7M 15D")
    $intdate->sec;                   # accurate number of seconds in interval
    $intdate->month;                 # accurate number of months in interval
    $reldate->to_sec;                # number of seconds in relative date (inaccurate)
    $intdate->includes("2013-01-01") # returns -1, 0, or 1
    
    $days_between = (Class::Date->new('2001-11-12')-'2001-07-04')->day;
    
    # comparison between absolute dates
    print $date1 > $date2 ? "I am older" : "I am younger";
    
    # comparison between relative dates
    print $reldate1 > $reldate2 ? "I am faster" : "I am slower";
    
    # Adding / Subtracting months and years are sometimes tricky:
    print date("2001-01-29") + '1M' - '1M'; # gives "2001-02-01"
    print date("2000-02-29") + '1Y' - '1Y'; # gives "2000-03-01"
    
    # Named interface ($date2 does not necessary to be a Class::Date object)
    $date1->string;               # same as $date1 in scalar context
    $date1->subtract($date2);     # same as $date1 -= $date2
    $date1->subtract_new($date2); # same as $date1 - $date2
    $date1->add($date2);          # same as $date1 += $date2
    $date1->add_new($date2);      # same as $date1 + $date2
    $date1->compare($date2);      # same as $date1 <=> $date2
    
    $reldate1->sec;               # same as $reldate1 in numeric or scalar context
    $reldate1->compare($reldate2);# same as $reldate1 <=> $reldate2
    $reldate1->add($reldate2);    # same as $reldate1 + $reldate2
    $reldate1->neg                # used for subtraction


=head1 CLASS METHODS

=head4 new($epoch | \@ymdhms | \%ymdhms | $iso_fmt | $date, [$timezone])

Creates a date object.

If $timezone is present, created object will operate as if C<tzset($timezone)> was called, but without calling C<tzset()>.

If $timezone is absent (or undef or ""), $date uses local timezone.
Further changes of local timezone via C<tzset()> won't affect constructed object.

=over

=item 123456 or "123456"

Treated as 64-bit UNIX timestamp. To define a date below 1970 year, use negative timestamp.

=item [$year, $month, $day, $hour, $min, $sec]

If some args are missing, will use defaults [2000,1,1,0,0,0]
    
=item {year => x, month => x, day => x, hour => x, min => x, sec => x}

If some args are missing, will use defaults defined in previous section.

=item "YYYY-MM-DD HH:MM:SS" or "YYYY/MM/DD HH:MM:SS"

A standard ISO(-like) date format. Additional ".fraction" part is ignored.
Any number of trailing parameters can be missing. So the actual format is "YYYY-[MM[-DD[ HH[:MM[:SS[.MS]]]]]]"
Minimal string is "YYYY-". Fractional part of seconds will be ignored.
If some args are missing, will use defaults defined in previous section.

=item Another date object

Clones another object.

If $timezone parameter is absent (or undef or ""), newly created date will use $date's timezone.
Otherwise constructed date is converted to timezone $timezone preserving YMDhms information.

=back

If there is any error while creating an object, properties error() and errstr() will be set.
The object itself will return false in boolean context, empty string in string context and so on.

=head1 FUNCTIONS

=head4 now()

Same as Panda::Date->new(time()) but runs faster.

=head4 today()

Same as Panda::Date->new(time())->truncate but runs faster.

=head4 today_epoch()

Same as today()->epoch but runs faster.

=head4 string_format([$format])

strftime-compatible format that is used to stringify the date with '.', "", to_string(), string() or as_string().
If it's false (the default) then iso() is used.

=head4 range_check([$true_false])

If parts of the date are invalid or the whole date is not valid, e.g. 2001-02-31 then:

when range_check is not set (the default), then these date values are automatically converted to a valid date (normalized): 2001-03-03

when range_check is set, then a date "2001-02-31" became invalid date and error() is set to E_RANGE.

=head4 date($epoch | \@ymdhms | \%ymdhms | $iso_fmt | $date, [$timezone])

Same as Panda::Date->new($arg, [$timezone])

=head4 rdate($rel_string | $seconds | \@rel_array | \%rel_hash | $reldate)

Same as Panda::Date::Rel->new($arg)
    
=head4 rdate($from, $till)

Same as Panda::Date::Rel->new($from, $till)
    
=head4 idate($epoch | \@ymdhms | \%ymdhms | $iso_fmt | $date, $epoch | \@ymdhms | \%ymdhms | $iso_fmt | $date)

Same as Panda::Date::Int->new($arg1, $arg2)


=head1 OBJECT METHODS

=head4 set($epoch | \@ymdhms | \%ymdhms | $iso_fmt | $date)

Set date from argument or another date. This is much faster than creating new object.

=head4 epoch([$epoch])

UNIX timestamp (64bit)

=head4 year([$year])

Year [-2**31, 2**31-1]

=head4 _year([$year])

Year (year() - 1900)

=head4 yr([$yr])

Last 2 digits of the year. [0-99]

=head4 month([$mon]), mon

Month [1-12]

=head4 _month([$mon]), _mon

Month [0-11]

=head4 day([$day]), mday, day_of_month

Day of month [1-31]

=head4 hour([$hour])

[0-23]

=head4 min([$min]), minute

[0-59]

=head4 sec([$sec]), second

[0-60]

=head4 wday([$wday]), day_of_week

Day of week. 1 = Sunday, 2 = Monday, ... , 7 = Saturday.
If you pass an argument then another day of the same week will be set.

=head4 _wday([$_wday])

Day of week. 0 = Sunday, 1 = Monday, ... , 6 = Saturday.
If you pass an argument then another day of the same week will be set.

=head4 ewday([$ewday])

Day of week (Europe-friendly). 1 = Monday, ..., 7 = Sunday.
If you pass an argument then another day of the same week will be set.

=head4 yday([$yday]), day_of_year

Day of the year [1-366].
If you pass an argument then another day of the same year will be set.

=head4 _yday([$_yday])

Day of the year [0-365].
If you pass an argument then another day of the same year will be set.

=head4 isdst(), daylight_savings()

Is daylight savings time in effect now (true/false).

=head4 strftime($format)

Works like strftime from C POSIX

=head4 monthname(), monname()

Full name of the month in the genitive

=head4 wdayname(), day_of_weekname()

Full name of the day in the nominative case.

=head4 hms()

Same as C<strftime('%H:%M:%S')> but much faster

=head4 ymd()

Same as C<strftime('%Y/%m/%d')> but much faster

=head4 mdy()

Same as C<strftime('%m/%d/%Y')> but much faster

=head4 dmy()

Same as C<strftime('%d/%m/%Y')> but much faster

=head4 "", to_string(), string(), as_string()

By default returns C<iso()>. String format can be changed via C<string_format()>

=head4 'bool', to_bool()

Called implicitly in boolean context

    if ($date)
    $date ? EXPR1 : EXPR2
    $date && $something
    
Returns TRUE if date has no errors (i.e. has no parsing or out of range errors, etc), otherwise FALSE

=head4 '0+', to_number()

Returns C<epoch()> in numeric context

=head4 iso(), sql()

Same as C<strftime('%Y-%m-%d %H:%M:%S')> but much faster

=head4 mysql()

Same as C<strftime('%Y%m%d%H%M%S')> but much faster

=head4 ampm()

Returns string 'AM' or 'PM'

=head4 meridiam()

Returns time in "11:35 AM" format (american 12h style)

=head4 gmtoff()

Returns current timezone offset from UTC in seconds

=head4 tzname()

Returns the name of the object's timezone (Europe/Moscow, America/New_York, etc).

=head4 tzabbr()

Returns timezone abbreviation (EST, EET, etc) - may change when the date changes isdst/nodst.

=head4 tzlocal()

Returns TRUE if this object's timezone is set as local.

=head4 tz([$newzone])

With no arguments returns information about object's timezone. See L<Panda::Time/tzget([$zone])>.

With argument changes the timezone of current object to $newzone preserving YMDhms information (epoch may change) and 
returns nothing.

=head4 to_tz($newzone)

Changes the timezone of current object to $newzone in a way that changed date still points to the same time moment (same epoch).
YMDhms info may change. Returns nothing.

=head4 array()

Returns 6 elements list - $year,$month,$day,$hour,$min,$sec.
$year is year() [2013=2013]
$month is month() [1-12]

=head4 aref()

Same as [array()] (array reference)

=head4 struct()

Returns 9 elements list - $sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst
$year is _year()  [113 = 2013]
$month is _month() [0-11]
$wday is _wday() [0-6]
$yday is _yday() [0-365]

=head4 sref()

Same as [struct()] (array reference)

=head4 hash()

Returns key-value list. Keys are 'year', 'month', 'day', 'hour', 'min', 'sec'
year, month are human-friendly (2013 year, month [1-12])

=head4 href()

Same as {href()} (hash reference)

=head4 clone([\@diff | \%diff, [$timezone]])

Returns copy of the date.

If you pass a hash or array ref then date is cloned with changes described in the hash/array.
Hash keys: 'year' (YYYY), 'month' [1-12], 'day', 'hour', 'min', 'sec'.
Array: [$year (YYYY), $month [1-12], $day, $hour, $min, $sec]

If any values in hash or array are absent (or = undef or = -1) the appropriate field of date is not changed.

If $timezone parameter is absent (or undef or ""), newly created date will use $date's timezone.
Otherwise constructed date is converted to timezone $timezone preserving YMDhms information.

=head4 month_begin_new()

Returns the beggining of month. Only day of month is changed, HMS are preserved.

=head4 month_begin()

Same as C<month_begin_new()> but changes current object instead of cloning.

=head4 month_end_new()

Returns the end of month. Only day of month is changed, HMS are preserved.

=head4 month_end()

Same as C<month_end_new()> but changes current object instead of cloning.

=head4 days_in_month()

Returns the number of days in month

=head4 error()

Returns error code occured during creating or cloning object (if any). If no errors returns E_OK.

=head4 errstr()

Returns error string if any, otherwise undef.

=head4 truncate_new()

Return copy of the current date with HMS set to 0. Same as C<clone({hour => 0, min => 0, sec => 0})>, but much faster.

=head4 truncate()

Same as C<truncate_new()> but changes current object instead of cloning. It's extremely faster.

=head4 '<=>', 'cmp', compare($date | $iso_string | $epoch | \@array | \%hash)

Compares 2 dates and returns -1, 0 or 1. If second operand is not an object then it's created.
If second operand is object but not Panda::Date then it croaks.

=head4 '+', add_new($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Adds a relative date to date object. If second operand is not an object then it's created (L<Panda::Date::Rel>).

=head4 '+=', add($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as C<add_new()> but changes current object instead of creating new one.

=head4 '-', subtract_new($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash | $date | $iso_string)

Subtracts a relative date or another date from the date object. In case of relative date the result is a L<Panda::Date> object.
Otherwise the result is L<Panda::Date::Int>.
If second operand is not an object then it's created (L<Panda::Date::Rel> or L<Panda::Date>).

=head4 '-=', subtract($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as C<subtract()> but changes current object instead of creating new one. Operand can only be a L<Panda::Date::Rel> object.

=head1 CONSTANTS

=head4 E_OK

No errors

=head4 E_UNPARSABLE

Wrong date string format

=head4 E_RANGE

Invalid date (or date part) supplied when range_check() is in effect

=head4 YEAR

Constant for rdate("1Y"). These (YEAR...SEC) objects are constants (read-only).

If you try to change these objects they'll croak.

=head4 MONTH

Constant for rdate("1M").

=head4 DAY

Constant for rdate("1D").

=head4 HOUR

Constant for rdate("1h").

=head4 MIN

Constant for rdate("1m").

=head4 SEC

Constant for rdate("1s").

=head1 OPERATOR OVERLOAD RULES

See screenshot L<http://crazypanda.ru/v/clip2net/a/v/ri93sO22KI.png>

=head1 Class::Date INCOMPABILITIES

=over

=item day_of_week() returns wday()

In Class::Date it returns _wday()

=item yday(), day_of_year() return [1-366]

In Class::Date they return [0-365]. If you need that behaviour, use _yday() method.

=item hash() and href() methods return 6 elements

In Class::Date they return 13 elements: additionally _year, _month, wday, yday, isdst, epoch, minute

=item clone() receives hash reference and less keys are supported in there.

Class::Date's clone() receives list of key-value pairs and supports key aliases like 'mon' etc.

=item there is no DST_ADJUST setting.

Panda::Date always performs all calculations with DST_ADJUST enabled.

=item Panda::Date::Rel constructors don't support ISO/SQL date format ("YYYY-MM-DD HH:MM:SS")

Because it's a DATE format NOT RELATIVE.

=item Panda::Date::Rel stringifies to "2M 3D 100s"

Class::Date::Rel stringifies to approximate number of seconds in interval (useless imho)

=item Panda::Date::Rel consists of all 6 params: YMDhms.

Class::Date::Rel consists of only months and seconds.

=item Panda::Date::Rel's sec/min/hour/day/month/year returns properties of object.

If you have relative date "1Y 2M", C<year()> would return 1, C<month()> - 2, C<day()> - 0, etc. If you need to calculate
all the period in, for example, months, use C<to_month()> (would return 14).
Such calculations can be inaccurate, for example, rdate("1M")->to_sec

=item subtracting date from another date returns L<Panda::Date::Int> object, not a L<Panda::Date::Rel>

L<Panda::Date::Int> is an Interval object and is an absolutely new term.

=back

=head1 STORABLE SERIALIZATION

Storable serialization is fully supported. That means you're able to freeze Panda::Date::* objects and 
thaw serialized data back without losing any date information.

If you serialize a date object which was created with personal timezone (second arg to constructor),
then it will be deserialized exactly in the same timezone.

If a date object is in local timezone, then it will be deserialized in local timezone too (which may differ on differrent servers), 
but it's guaranteed that those two dates will point to the same time moment (epoch is preserved).

For example:

    tzset('Europe/Moscow');
    my $date = date("2014-01-01");
    my $frozen = freeze $date;
    tzset('America/New_York');
    my $date2 = thaw $frozen;
    $date == $date2; # true, because $date->epoch == $date2->epoch
    say $date;  # 2014-01-01 00:00:00
    say $date2; # 2013-12-31 15:00:00

=head1 CAVEATS

=over

=item Panda::Date doesn't support subclassing for now.

If you subclass Panda::Date it won't work correct.

=item As any other C++-class-based framework, you can't clone Panda::Date::* objects using serializers or clone utils.

You will receive SIGSEGV. If you want to clone a Panda::Date::* object, use it's clone() method.

However, cloning and serializing/deserializing via L<Storable> is fully supported. Don't use it just to clone and object
because it's 20x times slower than calling C<clone()>.

=back

=head1 PERFOMANCE

Panda::Date operates 40-70x faster than Class::Date, tests were performed on Core i7 3.2Ghz, MacOSX Lion, perl 5.12.4

    my $cdate = new Class::Date("2013-06-05 23:45:56");
    my $date  = new Panda::Date("2013-06-05 23:45:56");
    my $crel = Class::Date::Rel->new("1M");
    my $rel  = rdate("1M");
    
    timethese(-1, {
        cdate_new_str   => sub { new Class::Date("2013-01-25 21:26:43"); },
        panda_new_str   => sub { new Panda::Date("2013-01-25 21:26:43"); },
        cdate_new_epoch => sub { new Class::Date(1000000000); },
        panda_new_epoch => sub { new Panda::Date(1000000000); },
        panda_new_reuse => sub { state $date = new Panda::Date(0); $date->set(1000000000); },
        
        cdate_now => sub { Class::Date->now; },
        panda_now => sub { now(); },
        
        cdate_truncate     => sub { $cdate->truncate },
        panda_truncate_new => sub { $date->truncate_new },
        panda_truncate     => sub { $date->truncate },
        cdate_today        => sub { Class::Date->now->truncate; },
        panda_today1       => sub { now()->truncate; },
        panda_today2       => sub { today(); },
        cdate_stringify    => sub { $cdate->string },
        panda_stringify    => sub { $date->to_string },
        cdate_strftime     => sub { $cdate->strftime("%H:%M:%S") },
        panda_strftime     => sub { $date->strftime("%H:%M:%S") },
        cdate_clone_simple => sub { $cdate->clone },
        panda_clone_simple => sub { $date->clone },
        cdate_clone_change => sub { $cdate->clone(year => 2008, month => 12) },
        panda_clone_change => sub { $date->clone({year => 2008, month => 12}) },
        cdate_rel_new_sec  => sub { new Class::Date::Rel 1000 },
        pdate_rel_new_sec  => sub { new Panda::Date::Rel 1000 },
        cdate_rel_new_str  => sub { new Class::Date::Rel "1Y 2M 3D 4h 5m 6s" },
        panda_rel_new_str  => sub { new Panda::Date::Rel "1Y 2M 3D 4h 5m 6s" },
        cdate_add          => sub { $cdate = $cdate + '1M' },
        panda_add_new      => sub { $date = $date + '1M' },
        panda_add          => sub { $date += '1M' },
        panda_add2         => sub { $date += MONTH },
        panda_add3         => sub { $date->month($date->month+1) },
        cdate_compare      => sub { $cdate == $cdate },
        panda_compare      => sub { $date == $date },
    });
    
    #RESULTS
    
    #cdate_new_epoch:  2 wallclock secs ( 1.11 usr +  0.00 sys =  1.11 CPU) @ 59609.01/s (n=66166)
    #panda_new_epoch:  1 wallclock secs ( 1.08 usr +  0.01 sys =  1.09 CPU) @ 1485434.86/s (n=1619124)
    #cdate_new_str:  1 wallclock secs ( 1.09 usr +  0.01 sys =  1.10 CPU) @ 19549.09/s (n=21504)
    #panda_new_str:  1 wallclock secs ( 1.01 usr +  0.00 sys =  1.01 CPU) @ 1238753.47/s (n=1251141)
    #panda_new_reuse:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 5242879.05/s (n=5505023)
    
    #cdate_now:  1 wallclock secs ( 1.11 usr +  0.00 sys =  1.11 CPU) @ 55350.45/s (n=61439)
    #panda_now:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 1341379.63/s (n=1448690)
    
    #cdate_truncate:  1 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 25120.56/s (n=26879)
    #panda_truncate:  1 wallclock secs ( 1.02 usr +  0.00 sys =  1.02 CPU) @ 7710116.67/s (n=7864319)
    #panda_truncate_new:  1 wallclock secs ( 1.00 usr +  0.00 sys =  1.00 CPU) @ 1376255.00/s (n=1376255)
    
    #cdate_today:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 16591.67/s (n=17919)
    #panda_today1:  1 wallclock secs ( 1.03 usr +  0.00 sys =  1.03 CPU) @ 1027823.30/s (n=1058658)
    #panda_today2:  1 wallclock secs ( 1.03 usr +  0.01 sys =  1.04 CPU) @ 1323322.12/s (n=1376255)
    
    #cdate_stringify:  1 wallclock secs ( 1.09 usr +  0.00 sys =  1.09 CPU) @ 92839.45/s (n=101195)
    #panda_stringify:  2 wallclock secs ( 1.09 usr +  0.00 sys =  1.09 CPU) @ 5072344.04/s (n=5528855)
    
    #cdate_strftime:  1 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 101433.02/s (n=107519)
    #panda_strftime:  2 wallclock secs ( 1.06 usr +  0.01 sys =  1.07 CPU) @ 1513200.00/s (n=1619124)
    
    #cdate_clone_simple:  1 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 26796.26/s (n=28672)
    #panda_clone_simple:  2 wallclock secs ( 1.03 usr +  0.00 sys =  1.03 CPU) @ 1670213.59/s (n=1720320)
    #cdate_clone_change:  2 wallclock secs ( 1.11 usr +  0.00 sys =  1.11 CPU) @ 25830.63/s (n=28672)
    #panda_clone_change:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 637154.63/s (n=688127)
    
    #cdate_rel_new_sec:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 245059.26/s (n=264664)
    #cdate_rel_new_str:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 68265.71/s (n=71679)
    #pdate_rel_new_sec:  2 wallclock secs ( 1.02 usr +  0.00 sys =  1.02 CPU) @ 1420284.31/s (n=1448690)
    #panda_rel_new_str:  1 wallclock secs ( 1.01 usr +  0.00 sys =  1.01 CPU) @ 1238753.47/s (n=1251141)
    
    #cdate_add:  1 wallclock secs ( 1.09 usr +  0.00 sys =  1.09 CPU) @ 17934.86/s (n=19549)
    #panda_add:  0 wallclock secs ( 1.01 usr +  0.00 sys =  1.01 CPU) @ 4542099.01/s (n=4587520)
    #panda_add2:  1 wallclock secs ( 1.03 usr +  0.00 sys =  1.03 CPU) @ 4858802.91/s (n=5004567)
    #panda_add3:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 2759410.48/s (n=2897381)
    #panda_add_new:  2 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 1180321.70/s (n=1251141)
    
    #cdate_compare:  1 wallclock secs ( 1.10 usr +  0.00 sys =  1.10 CPU) @ 71087.27/s (n=78196)
    #panda_compare:  2 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 3674914.95/s (n=3932159)

=head1 AUTHOR

Pronin Oleg <syber@cpan.org>, Crazy Panda, CP Decision LTD

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
 
1;
