package Panda::Date;
use parent 'Panda::Export';
use 5.012;
use Panda::Date::Rel;
use Panda::Date::Int;

our $VERSION = '1.4';

=head1 NAME

Panda::Date - fast Class::Date compatible framework. In C :-)

=cut

use Panda::Export {
    E_OK         => 0,
    E_UNPARSABLE => 1,
    E_RANGE      => 2,
};

use overload '""'     => \&to_string,
             'bool'   => \&to_bool,
             '0+'     => \&to_number,
             '<=>'    => \&compare,
             'cmp'    => \&compare,
             '+'      => \&add,
             '+='     => \&add_me,
             '-'      => \&subtract,
             '-='     => \&subtract_me,
             fallback => 1;

require XSLoader;
XSLoader::load('Panda::Date', $VERSION);

# can't place this into compile-time code because there is no XS code at that time.
Panda::Export->import({
    SEC          => rdate_const("1s"),
    MIN          => rdate_const("1m"),
    HOUR         => rdate_const("1h"),
    DAY          => rdate_const("1D"),
    MONTH        => rdate_const("1M"),
    YEAR         => rdate_const("1Y"),
});

=head1 DESCRIPTION

Panda::Date is almost fully compatible with Class::Date, but has several more features and much greater perfomance.
It is 100% written in C/C++.

By itself, Panda::Date supports dates between -2**31 and 2**31-1 years. But because of most OS mktime's restrictions
only [1900, 2**31-1] years are supported.

=head1 SYNOPSIS

    use Panda::Date qw/now date today rdate idate :const/;
    
    my $date = Panda::Date->new($epoch);
    $date = Panda::Date->new([$y,$m,$d,$h,$m,$s]);
    $date = Panda::Date->new({year => $y, month => $m, day => $d, hour => $h, min => $m, sec => $s});
    $date = Panda::Date->new("2013-03-05 23:45:56");
    $date = now; # same as Panda::Date->new(time()) but faster
    $date = Panda::Date::now();
    $date = Panda::Date->now;
    $date = today; # same as Panda::Date->new(time())->truncate but faster
    $date = Panda::Date::today();
    $date = Panda::Date->today;
    
    # create using function 'date'
    $date = date [$year,$month,$day,$hour,$min,$sec]; 
    $date = date { year => $year, month => $month, day => $day, hour => $hour, min => $min, sec => $sec };
    $date = date "2001-11-12 07:13:12";
    $date = date 123456789;
    
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
    
    $date;              # prints the date in default output format (SQL format)
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
    $date->strftime($format) # POSIX strftime (without the huge POSIX.pm)
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
    $date->sql          # 2000-02-29 12:21:11
    $date->tzoffset     # timezone-offset (in seconds)
    $date->tz           # returns the base timezone as you specify, eg: CET
    $date->tzdst        # returns the real timezone with dst information, eg: CEST
    
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
    $new_date = $date->clone({year => 1977, sec => 14});
    # valid keys: year, _year, month, _month, day, hour, min, sec
    
    $date->month_begin  # First day of the month (date object)
    $date->month_end    # Last day of the month
    $date->days_in_month # 28..31
    
    # changing date stringify format globally
    Panda::Date->string_format("%Y%m%d%H%M%S");
    print $date       # result: 20011222000000
    Panda::Date->string_format(undef);
    print $date       # result: 2000-02-29 12:21:11
    Panda::Date->string_format("%Y/%m/%d");
    print $date       # result: 1994/10/13
    
    # error handling
    $a = date($date_string);
    if ($a) { # valid date
      ...
    } else { # invalid date
      if ($a->error == E_UNPARSABLE) { ... }
      print $a->errstr;
    }
    
    # "month-border adjust" flag 
    Panda::Date->month_border_adjust(0); # this is the default
    print date("2001-01-31")+'1M'; # will print 2001-03-03
    Panda::Date->month_border_adjust(1);
    print date("2001-01-31")+'1M'; # will print 2001-02-28
    
    # date range check
    Panda::Date->range_check(0); # this is the default
    print date("2001-02-31"); # will print 2001-03-03
    Panda::Date->range_check(1);
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
    
    $intdate = $date1-$date2;
    $intdate2 = date('2000-11-12')-'2000-11-10';
    $intdate3    = $date3-'1977-11-10';
    
    $intdate = date("2013-10-25") - "2012-03-10";
    $intdate->from;                # lower date in interval (2012-03-10)
    $intdate->till;                # upper date in interval (2013-10-25)
    $reldate = $intdate->relative; # relative date ("1Y 7M 15D")
    $intdate->sec;                 # accurate number of seconds in interval
    $intdate->month;               # accurate number of months in interval
    $reldate->to_sec;              # number of seconds in relative date (inaccurate)
    
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
    $date1->subtract($date2);     # same as $date1 - $date2
    $date1->add($date2);          # same as $date1 + $date2
    $date1->compare($date2);      # same as $date1 <=> $date2
    
    $reldate1->sec;               # same as $reldate1 in numeric or scalar context
    $reldate1->compare($reldate2);# same as $reldate1 <=> $reldate2
    $reldate1->add($reldate2);    # same as $reldate1 + $reldate2
    $reldate1->neg                # used for subtraction

=head1 CLASS METHODS

=head4 new($epoch | \@ymdhms | \%ymdhms | $sql_fmt | $date)

Creates a date object using one of these source data types:

=over

=item 123456 or "123456"

Treated as 64-bit UNIX timestamp. To define a date below 1970 year, use negative timestamp.

=item [$year, $month, $day, $hour, $min, $sec]

If some args are missing, will use defaults [2000,1,1,0,0,0]
    
=item {year => x, month => x, day => x, hour => x, min => x, sec => x}

If some args are missing, will use defaults defined in previous section.

=item "YYYY-MM-DD HH:MM:SS"

Any number of trailing parameters can be missing. So the actual format is "YYYY-[MM[-DD[ HH[:MM[:SS[.MS]]]]]]"
Minimal string is "YYYY-". Fractional part of seconds will be ignored.
If some args are missing, will use defaults defined in previous section.

=item Another date object

Clones another object

=back

If there is any error while creating an object, properties error() and errstr() will be set.
The object itself will return false in boolean context, empty string in string context and so on.

=head4 now()

Same as

    Panda::Date->new(time());
    
but runs much faster. Can be called as function, class method or object method.

=head4 today()

Same as 

    Panda::Date->new(time())->truncate
    
but runs much faster. Can be called as function, class method or object method.

=head4 string_format([$format])

strftime-compatible format that will be used to stringify the date with '.', "", to_string(), string() or as_string().
If it's false (the default) then sql() will be used.

=head4 month_border_adjust([$bool])

Used to switch on or off the month-adjust feature. This is used only when someone adds months or years to a 
date and then the resulted date became invalid. An example: adding one month to "2001-01-31" will result "2001-02-31", 
and this is an invalid date.

When month_border_adjust is false, this result simply normalized, and becomes "2001-03-03". This is the default behaviour.

When month_border_adjust is true, this result becomes "2001-02-28". So when the date overflows, then it returns the last day insted.

Both settings keeps the time information.

=head4 range_check([$true_false])

If parts of the date are invalid or the whole date is not valid, e.g. 2001-02-31 then:

when range_check is not set (the default), then these date values are automatically converted to a valid date (normalized): 2001-03-03

when range_check is set, then a date "2001-02-31" became invalid date and error() is set to E_RANGE.

=head1 FUNCTIONS

=head4 date($epoch | \@ymdhms | \%ymdhms | $sql_fmt | $date)

Same as

    Panda::Date->new($arg);

=head4 now(), today()

See CLASS METHODS

=head4 rdate($rel_string | $seconds | \@rel_array | \%rel_hash | $reldate)

Same as

    Panda::Date::Rel->new($arg);
    
=head4 rdate($from, $till)

Same as

    Panda::Date::Rel->new(from, till);
    
=head4 idate($epoch | \@ymdhms | \%ymdhms | $sql_fmt | $date, $epoch | \@ymdhms | \%ymdhms | $sql_fmt | $date)

Same as

    Panda::Date::Int->new($arg1, $arg2);


=head1 OBJECT METHODS

=head4 set_from($epoch | \@ymdhms | \%ymdhms | $sql_fmt | $date)

Set date from data or another date. This is much faster than creating new object.

=head4 epoch([$epoch])

UNIX timestamp (64bit)

=head4 year([$year])

Year [1900, 2**31-1]

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

Works like strftime from POSIX (POSIX is not used!)

=head4 monthname(), monname()

Full name of the month in the genitive

=head4 wdayname(), day_of_weekname()

Full name of the day in the nominative case.

=head4 hms()

Same as strftime('%H:%M:%S') but much faster

=head4 ymd()

Same as strftime('%Y/%m/%d') but much faster

=head4 mdy()

Same as strftime('%m/%d/%Y') but much faster

=head4 dmy()

Same as strftime('%d/%m/%Y') but much faster

=head4 "", to_string(), string(), as_string()

By default returns sql(). String format can be changed via string_format()

=head4 'bool', to_bool()

Called implicitly in boolean context

    if ($date)
    $date ? EXPR1 : EXPR2
    $date && $something
    
Returns TRUE if date has no errors (i.e. has no parsing or out of range errors, etc), otherwise FALSE

=head4 '0+', to_number()

Returns epoch() in numeric context

=head4 sql()

Same as strftime('%Y-%m-%d %H:%M:%S') but much faster

=head4 ampm()

Returns string 'AM' or 'PM'

=head4 meridiam()

Returns time in "11:35 AM" format (american 12h style)

=head4 tzoffset()

Returns current timezone offset from UTC in seconds

=head4 tz()

Returns base name of the current timezone

=head4 tzdst()

Returns full name of the current timezone (depends on whether DST is active at the moment pointed to by date or not)

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

=head4 clone([\%diff])

Returns copy of the date. If you pass a hash ref then new date object will have these changes.

Supported keys: 'year' (YYYY), '_year' (YYYY-1900), 'month' [1-12], '_month' [0-11], 'day', 'hour', 'min', 'sec'.

=head4 month_begin()

Returns the beggining of month. Only day of month is changed, HMS are preserved.

=head4 month_begin_me()

Same as month_begin() but changes current object instead of cloning.

=head4 month_end()

Returns the end of month. Only day of month is changed, HMS are preserved.

=head4 month_end_me()

Same as month_end() but changes current object instead of cloning.

=head4 days_in_month()

Returns the number of days in month

=head4 error()

Returns error code occured during creating or cloning object (if any). If no errors returns E_OK.

=head4 errstr()

Returns error string if any, otherwise undef.

=head4 truncate()

Return copy of the current date with HMS set to 0. Same as ->clone({hour => 0, min => 0, sec => 0}), but much faster.

=head4 truncate_me()

Same as truncate_me() but changes current object instead of cloning. This is extremely faster.

=head4 '<=>', 'cmp', compare($date | $sql_string | $epoch | \@array | \%hash)

Compares 2 dates and returns -1, 0 or 1. If second operand is not an object then it's created.
If second operand is object but not Panda::Date then it croaks.

=head4 '+', add($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Adds a relative date to date object.  If second operand is not an object then it's created (L<Panda::Date::Rel>).

=head4 '+=', add_me($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as add() but changes current object instead of creating new one.

=head4 '-', subtract($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash | $date | $sql_string)

Subtracts a relative date or another date from the date object. In case of relative date the result is a L<Panda::Date> object.
Otherwise the result is L<Panda::Date::Int>.
If second operand is not an object then it's created (L<Panda::Date::Rel> or L<Panda::Date>).

=head4 '-=', subtract_me($reldate | $rel_string | $seconds | \@rel_array | \%rel_hash)

Same as subtract() but changes current object instead of creating new one.

=head1 CONSTANTS

=head4 E_OK

No errors

=head4 E_UNPARSABLE

Wrong date string format

=head4 E_RANGE

Invalid date (or date part) supplied when range_check() is in effect

=head4 YEAR

Constant for rdate("1Y"). These (YEAR...SEC) objects are constants (read-only).

If you try to change these objects you'll get an exception.

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

=item Panda::Date doesn't support per-object timezones yet.

It works in default (user) timezone. You can change it via $ENV{TZ} + POSIX::tzset.

=item Panda::Date constructor doesn't support "YYYYMMDDhhmmss" format as well as -DateParse feature

For now.

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
In Class::Date it is the default but you can disable DST_ADJUST (but i don't know why someone would do that).

=item Panda::Date::Rel constructors don't support SQL date format ("YYYY-MM-DD HH:MM:SS")

Because it's a DATE format NOT RELATIVE.

=item Panda::Date::Rel stringifies to "2M 3D 100s"

Class::Date::Rel stringifies to approximate number of seconds in interval (useless imho)

=item Panda::Date::Rel consists of all 6 params: YMDhms.

Class::Date::Rel consists of only months and seconds.

=item Panda::Date::Rel's sec/min/hour/day/month/year returns properties of object.

If you have relative date "1Y 2M", year() will return 1, month() - 2, day() - 0, etc. If you need to calculate
all the period in, for example, months, use ->to_month() (will return 14). Such calculations can be inaccurate, for example,
rdate("1M")->to_sec

=item subtracting date from another date returns L<Panda::Date::Int> object, not a L<Panda::Date::Rel>

L<Panda::Date::Int> is an Interval object and is an absolutely new term.

=back

=head1 CAVEATS

=over

=item Panda::Date doesn't support subclassing for now.

Subclassing is manually turned off because enabling it will drop 20% perfomance off because in XS ->isa() is much slower than ref($a) eq "xxx".

If you subclass Panda::Date it won't work correct.

=item As any other C++-class-based framework, you can't clone Panda::Date::* objects using serializers or clone utils.

You will receive SIGSEGV. If you want to clone a Panda::Date::* object, use it's clone() method.

However, cloning and serializing/deserializing via L<Storable> is supported as Panda::Date::* classes define special hooks for Storable.
But it's about 20 times slower than using clone() method.

=back

=head1 PERFOMANCE

Panda::Date operates 40-70x faster than Class::Date

    my $cdate = new Class::Date("2013-06-05 23:45:56");
    my $date  = new Panda::Date("2013-06-05 23:45:56");
    my $crel = Class::Date::Rel->new("1M");
    my $rel  = rdate("1M");
    my @buff;
    
    timethese(-1, {
        cdate_new_str   => sub { push @buff, new Class::Date("2013-01-25 21:26:43"); }, # push @buff to avoid calling DESTROY
        panda_new_str   => sub { push @buff, new Panda::Date("2013-01-25 21:26:43"); },
        cdate_new_epoch => sub { push @buff, new Class::Date(1000000000); },
        panda_new_epoch => sub { push @buff, new Panda::Date(1000000000); },
        panda_new_reuse => sub { state $date = new Panda::Date(0); $date->set_from(1000000000); },
        
        cdate_now => sub { Class::Date->now; },
        panda_now => sub { now(); },
        
        cdate_truncate    => sub { $cdate->truncate },
        panda_truncate_me => sub { $date->truncate_me },
        panda_truncate    => sub { $date->truncate },
        cdate_today  => sub { Class::Date->now->truncate; },
        panda_today1 => sub { now()->truncate_me; },
        panda_today2 => sub { today(); },
        cdate_stringify => sub { $cdate->string },
        panda_stringify => sub { $date->to_string },
        cdate_strftime => sub { $cdate->strftime("%H:%M:%S") },
        panda_strftime => sub { $date->strftime("%H:%M:%S") },
        cdate_clone_simple => sub { $cdate->clone },
        panda_clone_simple => sub { $date->clone },
        cdate_clone_change => sub { $cdate->clone(year => 2008, month => 12) },
        panda_clone_change => sub { $date->clone({year => 2008, month => 12}) },
        cdate_rel_new_sec => sub { new Class::Date::Rel 1000 },
        pdate_rel_new_sec => sub { new Panda::Date::Rel 1000 },
        cdate_rel_new_str => sub { new Class::Date::Rel "1Y 2M 3D 4h 5m 6s" },
        panda_rel_new_str => sub { new Panda::Date::Rel "1Y 2M 3D 4h 5m 6s" },
        cdate_add     => sub { $cdate = $cdate + '1M' },
        panda_add     => sub { $date = $date + '1M' },
        panda_add_me  => sub { $date += '1M' },
        panda_add_me2 => sub { $date += MONTH },
        panda_add_me3 => sub { $date->month($date->month+1) },
        cdate_compare => sub { $cdate == $cdate },
        panda_compare => sub { $date == $date },
    });
    
    #RESULTS
    
    #cdate_new_epoch:  2 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 45386.90/s (n=47869)
    #panda_new_epoch:  2 wallclock secs ( 1.06 usr +  0.03 sys =  1.09 CPU) @ 1006632.23/s (n=1101004)
    #cdate_new_str:  1 wallclock secs ( 1.10 usr +  0.00 sys =  1.10 CPU) @ 15616.91/s (n=17203)
    #panda_new_str:  0 wallclock secs ( 0.98 usr +  0.09 sys =  1.07 CPU) @ 866252.61/s (n=927161)
    #panda_new_reuse:  2 wallclock secs ( 1.02 usr +  0.00 sys =  1.02 CPU) @ 7247433.28/s (n=7417295)
    
    #cdate_now:  1 wallclock secs ( 1.02 usr +  0.05 sys =  1.07 CPU) @ 41146.86/s (n=44040)
    #panda_now:  1 wallclock secs ( 1.02 usr +  0.11 sys =  1.12 CPU) @ 1043915.56/s (n=1174405)
    
    #cdate_truncate:  1 wallclock secs ( 1.09 usr +  0.00 sys =  1.09 CPU) @ 20277.41/s (n=22020)
    #panda_truncate:  2 wallclock secs ( 1.09 usr +  0.00 sys =  1.09 CPU) @ 1247845.29/s (n=1355082)
    #panda_truncate_me:  0 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 8289918.12/s (n=8808038)
    
    #cdate_today:  1 wallclock secs ( 1.04 usr +  0.02 sys =  1.05 CPU) @ 13048.41/s (n=13762)
    #panda_today1:  1 wallclock secs ( 0.99 usr +  0.07 sys =  1.06 CPU) @ 592136.47/s (n=629145)
    #panda_today2:  1 wallclock secs ( 0.95 usr +  0.09 sys =  1.03 CPU) @ 657009.45/s (n=677541)
    
    #cdate_stringify:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 84136.12/s (n=88080)
    #panda_stringify:  1 wallclock secs ( 1.03 usr +  0.00 sys =  1.03 CPU) @ 4019354.18/s (n=4144959)
    
    #cdate_strftime:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 91452.18/s (n=95739)
    #panda_strftime:  2 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 1441724.24/s (n=1531832)
    
    #cdate_clone_simple:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 21747.67/s 
    #panda_clone_simple:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 1256887.65/s
    #cdate_clone_change:  2 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 20878.22/s 
    #panda_clone_change:  1 wallclock secs ( 1.04 usr +  0.00 sys =  1.04 CPU) @ 605492.93/s 
    
    #cdate_rel_new_sec:  2 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 145888.46/s (n=157286)
    #cdate_rel_new_str:  1 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 43176.47/s (n=45875)
    #panda_rel_new_sec:  2 wallclock secs ( 1.10 usr +  0.00 sys =  1.10 CPU) @ 695299.63/s (n=765916)
    #panda_rel_new_str:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 647203.34/s (n=677541)
    
    #cdate_add:  1 wallclock secs ( 1.09 usr +  0.02 sys =  1.10 CPU) @ 13881.19/s (n=15291)
    #panda_add:  1 wallclock secs ( 1.08 usr +  0.00 sys =  1.08 CPU) @ 907751.88/s (n=978670)
    #panda_add_me:  1 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 4389017.23/s (n=4697620)
    #panda_add_me2:  1 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 4702518.19/s (n=5033164)
    #panda_add_me3:  0 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 3036845.51/s (n=3202923)
    
    #cdate_compare:  1 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 60509.43/s (n=64764)
    #panda_compare:  1 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 4421289.41/s (n=4697620)

=head1 AUTHOR

Pronin Oleg <syber@cpan.org>, Crazy Panda, CP Decision LTD

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
 
1;
